pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'docker-hub'
        DOCKER_IMAGE = 'praveensise/trend-app'
        K8S_NAMESPACE = 'default'
    }

    triggers {
        gitpush()
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                sh 'echo "Building application..."'
                // e.g., for Node:
                // sh 'npm install'
                // sh 'npm test'
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CREDENTIALS) {
                        def app = docker.build("${DOCKER_IMAGE}:${env.BUILD_NUMBER}")
                        app.push()
                        // Optionally push "latest"
                        sh "docker tag ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ${DOCKER_IMAGE}:latest"
                        sh "docker push ${DOCKER_IMAGE}:latest"
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh """
             
                sed -i 's#image: .*#image: ${DOCKER_IMAGE}:latest#g' deployment.yaml

                kubectl apply -n ${K8S_NAMESPACE} -f deployment.yaml
                kubectl apply -n ${K8S_NAMESPACE} -f service.yaml

                echo "Current services:" 
                kubectl get svc -n ${K8S_NAMESPACE}
                """
            }
        }
    }

    post {
        success {
            echo "Deployment successful!"
        }
        failure {
            echo "Build or deployment failed!"
        }
    }
}
