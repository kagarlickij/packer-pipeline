pipeline {
    agent { node { label 'master' } }
    stages {
        stage('debug') {
            steps {
                sh """
                    printenv
                """
            }
        }
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
            when { allOf {
                expression { return env.GIT_BRANCH == 'origin/main'; }
                expression { return env.ghprbPullId == null; }
            } }
            steps {
                echo 'main'
                sh '''
                    packer init .
                    packer validate .
                    packer build -color=false template.pkr.hcl
                '''
            }
        }
    }
}
