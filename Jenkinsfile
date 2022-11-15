pipeline {
    agent { node { label 'master' } }
    stages {
        stage('PR') {
            when {
                branch 'PR-*'
            }
            steps {
                echo 'PR'
                sh '''
                    packer init .
                    packer validate .
                '''
            }
        }
        stage('main') {
            when {
                expression {
                    return env.BRANCH_NAME == 'main';
                }
            }
            steps {
                echo 'main'
                sh '''
                    packer init .
                    packer validate .
                    packer build template.pkr.hcl
                '''
            }
        }
    }
}
