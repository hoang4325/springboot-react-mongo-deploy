pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                checkout scm
            }
        }

        stage('GitOps tooling check') {
            steps {
                sh 'command -v git && command -v python3 && command -v gh'
            }
        }

        stage('Docker Build') {
            steps {
                dir('react-student-management') {
                    sh 'docker build -t hoang4325/student-app-web:$BUILD_NUMBER -t hoang4325/student-app-web:latest .'
                }
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER_ENV')]) {
                    sh '''
                        set +x
                        printf '%s' "$DOCKER_PASS" | docker login -u "$DOCKER_USER_ENV" --password-stdin
                    '''
                    sh 'docker push hoang4325/student-app-web:$BUILD_NUMBER'
                    sh 'docker push hoang4325/student-app-web:latest'
                }
            }
        }

        stage('Create GitOps PR') {
            steps {
                withCredentials([string(credentialsId: 'github-gitops-token', variable: 'GH_TOKEN')]) {
                    sh 'bash cicd-using-jenkins/gitops-create-pr.sh frontend "$BUILD_NUMBER"'
                }
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}
