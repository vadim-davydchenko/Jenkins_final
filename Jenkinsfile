pipeline {
    agent { label 'docker' }

    options { timeout(time: 10, unit: 'MINUTES') }

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
            when { branch 'develop' }
            steps {
                script {
                    def gitCommit = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                    def imageTag = "${gitCommit}-${env.BUILD_NUMBER ?: 'dev'}"

                    echo "Building Docker image ${IMAGE_NAME}:${imageTag}"
                    sh "docker build -t ${IMAGE_NAME}:${imageTag} ."

                    echo 'Scanning image with Trivy (HIGH/CRITICAL will fail build)'
                    sh "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --severity HIGH,CRITICAL --exit-code 1 ${IMAGE_NAME}:${imageTag}"

                    echo 'Pushing image to Nexus'
                    withCredentials([usernamePassword(credentialsId: 'nexus-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                          docker login -u \$DOCKER_USER --password \$DOCKER_PASS http://${REGISTRY_URL}
                          docker tag ${IMAGE_NAME}:${imageTag} ${REGISTRY_URL}/${IMAGE_NAME}:${imageTag}
                          docker push ${REGISTRY_URL}/${IMAGE_NAME}:${imageTag}
                        """
                    }
                }
            }
        }
    }

    post {
        failure {
            notifyTelegram("Сборка *FAILED* (возможно, уязвимости): ${env.JOB_NAME} #${env.BUILD_NUMBER}\n${env.BUILD_URL}")
        }
    }
}

def notifyTelegram(String message) {
    withCredentials([
        string(credentialsId: 'TELEGRAM_BOT_TOKEN', variable: 'TG_TOKEN'),
        string(credentialsId: 'TELEGRAM_CHAT_ID', variable: 'TG_CHAT_ID')
    ]) {
        def encoded = java.net.URLEncoder.encode(message, 'UTF-8')
        sh """
          curl -s -X POST "https://api.telegram.org/bot${TG_TOKEN}/sendMessage" \
               -d chat_id=${TG_CHAT_ID} \
               -d parse_mode=Markdown \
               --data-urlencode "text=${message}"
        """
    }
}
