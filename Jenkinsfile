def source_ami = "ami-0cc841fc27393aabc"

pipeline {
    agent { node { label 'master' } }
    stages {
        stage('validate PR') {
            when {
                expression { return env.ghprbPullId != null; }
            }
            steps {
                echo 'PR'
                sh """
                    packer init .
                    packer validate -var 'source_ami=${source_ami}' -var 'version=${BUILD_NUMBER}' .
                """
            }
        }
        stage('deploy from main') {
            when { allOf {
                expression { return env.GIT_BRANCH == 'origin/main'; }
                expression { return env.ghprbPullId == null; }
            } }
            environment {
                AWS_DEFAULT_REGION = "us-east-2"
                AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
                AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
            }
            steps {
                echo 'main'
                sh """
                    packer init .
                    packer validate -var 'source_ami=${source_ami}' -var 'version=${BUILD_NUMBER}' .
                    packer build -machine-readable -color=false -var 'source_ami=${source_ami}' -var 'version=${BUILD_NUMBER}' . | tee build.log
                """
                sh """
                    AMI_ID=\$(grep 'artifact,0,id' build.log | cut -d, -f6 | cut -d: -f2)
                    rm -f build.log
                    INSTANCE_ID=\$(aws ec2 run-instances \
                    --image-id \$AMI_ID \
                    --instance-type "t2.micro" \
                    --subnet-id "subnet-07b02bd4ddfe7a1c2" \
                    --security-group-ids "sg-0eb548430516a7188" \
                    --key-name "test-aws10-ohio" \
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
                //     aws ec2 deregister-image --image-id ${source_ami}
                // """
            }
        }
    }
}
