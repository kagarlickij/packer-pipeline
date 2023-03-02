def SOURCE_AMI = "ami-0f53f393debb4c3c0"

pipeline {
    agent { node { label 'master' } }
    stages {
        stage('validate PR') {
            when {
                expression { return env.ghprbPullId != null; }
            }
            steps {
                echo 'PR'
                script {
                    env.IMG_VERSION = sh (
                        script: 'head -n 1 changelog.md',
                        returnStdout: true
                    ).trim()
                    echo "[DEBUG] IMG_VERSION is: ${IMG_VERSION}"
                    env.IMG_NAME="test-packer-linux_v${IMG_VERSION}"
                    echo "[DEBUG] IMG_NAME is: ${IMG_NAME}"
                }
                sh """
                    EXISTING_IMG_CREATION_DATE=\$(aws ec2 describe-images --filters Name=name,Values=\$IMG_NAME | jq --raw-output '.Images[].CreationDate')
                    if [ ! -z "\$EXISTING_IMG_CREATION_DATE" ]; then
                        echo "[ERROR] Image already exists"
                        exit 1
                    else
                        echo "[INFO] Image doesn't exist yet"
                    fi
                """
                sh """
                    packer init .
                    packer validate -var 'source_ami=${SOURCE_AMI}' -var 'version=${IMG_NAME}' .
                """
            }
        }
    }
}