def source_ami = "ami-090f3f18d176e29f7"

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
                    packer build -color=false -var 'source_ami=${source_ami}' -var 'version=${BUILD_NUMBER}' .
                """
            }
        }
    }
}
