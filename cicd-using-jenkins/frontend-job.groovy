pipeline {
    agent any

    environment {
        REGISTRY_CREDS = 'docker-hub-credentials' // ID Credentials Jenkins của Docker Hub
        IMAGE_NAME = 'student-app-web'
        DOCKER_USER = 'hoang4325' // Thay thế bằng username Docker Hub của bạn
        TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                checkout scm
            }
        }

        stage('Docker Build') {
            steps {
                dir('react-student-management') {
                    sh "docker build -t ${DOCKER_USER}/${IMAGE_NAME}:${TAG} -t ${DOCKER_USER}/${IMAGE_NAME}:latest ."
                }
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${REGISTRY_CREDS}", passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER_ENV')]) {
                    sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER_ENV --password-stdin"
                    sh "docker push ${DOCKER_USER}/${IMAGE_NAME}:${TAG}"
                    sh "docker push ${DOCKER_USER}/${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Deploy') {
            steps {
                // Pull ảnh mới nhất và deploy chỉ container web
                sh "docker compose pull web"
                sh "docker compose up -d --no-deps --force-recreate web"
            }
        }
    }

    post {
        always {
            sh "docker logout"
        }
    }
}
