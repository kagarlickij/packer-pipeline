def SOURCE_AMI = "ami-01e1f544a628238ae" //TODO: switch to CentOS
def INSTANCE_TYPE = "t2.micro"
def SUBNET_ID = "subnet-07b02bd4ddfe7a1c2"
def SECURITY_GROUP = "sg-0eb548430516a7188"
def KEY_NAME = "test-aws10-ohio"

pipeline {
    agent { node { label 'master' } }
    stages {
        stage('Get input') {
            when { allOf {
                expression { return env.GIT_BRANCH == 'origin/main'; }
                expression { return env.ghprbPullId == null; }
            } }
            // environment {
            //     AWS_DEFAULT_REGION = "us-east-2"
            //     AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
            //     AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
            // }
            steps {
                script {
                    env.IMG_VERSION = sh (
                        script: 'head -n 1 changelog.md',
                        returnStdout: true
                    ).trim()
                    echo "[DEBUG] IMG_VERSION is: ${IMG_VERSION}"
                    env.IMG_NAME="test-packer-linux_v${IMG_VERSION}"
                    echo "[DEBUG] IMG_NAME is: ${IMG_NAME}"
                }
            }
        }
        stage('Check if image exists') {
            steps {
                sh """
                    EXISTING_IMG_CREATION_DATE=\$(aws ec2 describe-images --filters Name=name,Values=\$IMG_NAME | jq --raw-output '.Images[].CreationDate')
                    if [ ! -z "\$EXISTING_IMG_CREATION_DATE" ]; then
                        echo "[ERROR] Image already exists"
                        exit 1
                    else
                        echo "[INFO] Image doesn't exist yet"
                    fi
                """
            }
        }
        stage('Build image') {
            steps {
                sh """
                    packer init .
                    packer validate -var 'source_ami=${SOURCE_AMI}' -var 'img_name=${IMG_NAME}' .
                    packer build -machine-readable -color=false -var 'source_ami=${SOURCE_AMI}' -var 'img_name=${IMG_NAME}' . | tee build.log
                """
            }
        }
        stage('Test image') {
            steps {
                sh """
                    AMI_ID=\$(grep 'artifact,0,id' build.log | cut -d, -f6 | cut -d: -f2)
                    rm -f build.log
                    INSTANCE_ID=\$(aws ec2 run-instances \
                    --image-id \$AMI_ID \
                    --instance-type \'${INSTANCE_TYPE}' \
                    --subnet-id \'${SUBNET_ID}' \
                    --security-group-ids \'${SECURITY_GROUP}' \
                    --key-name \'${KEY_NAME}' \
                    --iam-instance-profile "Name=AmazonSSMManagedInstanceCore" \
                    --query 'Instances[0].InstanceId' \
                    --output text)
                    sleep 120
                    CMD_ID=\$(aws ssm send-command --instance-ids \$INSTANCE_ID --document-name "AWS-RunShellScript" --parameters 'commands=["free -m | grep Swap"]' --query "Command.CommandId" --output text)
                    sleep 5
                    SWAP_SIZE=\$(aws ssm get-command-invocation --command-id \$CMD_ID --instance-id \$INSTANCE_ID --query "StandardOutputContent" | awk '{print \$2}')
                    echo "SWAP_SIZE = \$SWAP_SIZE"
                    if [ \$SWAP_SIZE = "0" ]; then
                        echo "SWAP was not set"
                        aws ec2 terminate-instances --instance-ids \$INSTANCE_ID
                        exit 1
                    else
                        echo "SWAP was set successfully"
                        aws ec2 terminate-instances --instance-ids \$INSTANCE_ID
                    fi
                """
                // sh """
                //     echo "Checking AWS cli version" TODO: add check for AWS cli
                // """
            }
        }
        // stage('Delete old image') {
        //    steps {
        //         sh """
        //             aws ec2 deregister-image --image-id ${SOURCE_AMI}
        //         """
        //    }
        // }
    }
}
