pipeline {
    agent any

    environment {
        REGISTRY_CREDS = 'docker-hub-credentials' // ID Credentials Jenkins của Docker Hub
        IMAGE_NAME = 'student-app-api'
        DOCKER_USER = 'hoangnh' // Thay thế bằng username Docker Hub của bạn
        TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                checkout scm
            }
        }

        stage('Maven Build') {
            steps {
                dir('spring-boot-student-app-api') {
                    sh 'chmod +x mvnw'
                    sh './mvnw clean package -DskipTests'
                }
            }
        }

        stage('Docker Build') {
            steps {
                dir('spring-boot-student-app-api') {
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
                // Deploy local bằng Docker Compose restart api container
                sh "docker compose up -d api"
            }
        }
    }

    post {
        always {
            sh "docker logout"
        }
    }
}
