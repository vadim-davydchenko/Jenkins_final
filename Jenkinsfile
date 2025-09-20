pipeline {
    agent any

    environment {
        REGISTRY_URL = 'localhost:8082'
        REGISTRY_CREDS = 'nexus-credentials'
        IMAGE_NAME    = 'myapp'
    }
    stages {
        stage('Initialize') {
            steps {
                script {
                    def dockerHome = tool 'myDocker'
                    env.PATH = "${dockerHome}/bin:${env.PATH}"
                }
            }
        }
        stage('Build and Push') {
            steps {
                script {
                    def imageTag = "${env.BUILD_NUMBER}"

                    echo "Building Docker image ${IMAGE_NAME}:${imageTag}"
                    sh "docker build -t ${IMAGE_NAME}:${imageTag} ."

                    echo 'Scanning image with Trivy (HIGH/CRITICAL will fail build)'
                    sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --severity HIGH,CRITICAL --exit-code 1 ${IMAGE_NAME}:${imageTag}"

                    echo 'Pushing image to Nexus'
                    withCredentials([usernamePassword(credentialsId: 'nexus-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                          docker login -u $DOCKER_USER --password $DOCKER_PASS http://${REGISTRY_URL}
                          docker tag ${IMAGE_NAME}:${imageTag} ${REGISTRY_URL}/${IMAGE_NAME}:${imageTag}
                          docker push ${REGISTRY_URL}/${IMAGE_NAME}:${imageTag}
                        '''
                    }
                }
            }
        }
    }
}
