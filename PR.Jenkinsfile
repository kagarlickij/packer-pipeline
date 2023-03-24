def SOURCE_AMI = "ami-01e1f544a628238ae"

pipeline {
    agent { node { label 'master' } }
    stages {
        stage('Get input') {
            when {
                expression { return env.ghprbPullId != null; }
            }
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
        stage('Validate image build') {
            steps {
                sh """
                    packer init .
                    packer validate -var 'source_ami=${SOURCE_AMI}' -var 'img_name=${IMG_NAME}' .
                """
            }
        }
    }
}
