pipeline {
    agent any

    // Define standard environment variables
    environment {
        KUBECONFIG = "/var/lib/jenkins/.kube/config" 
        AWS_REGION = "us-east-1"
        DOCKERHUB_CREDENTIALS = 'docker-hub' 
        DOCKER_IMAGE = 'praveensise/trend-app'
        K8S_NAMESPACE = 'default'
    }

    // Trigger on GitHub push events
    triggers {
        githubPush()
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
                // Add your application build commands here (e.g., npm install, mvn package, etc.)
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    // Use the DOCKERHUB_CREDENTIALS ID to securely log in and build/push
                    docker.withRegistry('https://index.docker.io/v1/', DOCKERHUB_CREDENTIALS) {
                        def app = docker.build("${DOCKER_IMAGE}:${env.BUILD_NUMBER}")
                        app.push()
                        
                        // Push 'latest' tag for convenience
                        sh "docker tag ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ${DOCKER_IMAGE}:latest"
                        sh "docker push ${DOCKER_IMAGE}:latest"
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                // FIX: This credential ID must be the exact ID of your AWS Secret Key credential saved in Jenkins.
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'Aws-credentials', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']
                ]) {
                    sh """
                        echo "Using kubeconfig at: ${KUBECONFIG}"

                        # 1. Update the deployment.yaml with the new image tag
                        sed -i 's#image: .*#image: ${DOCKER_IMAGE}:latest#g' deployment.yaml

                        # 2. Apply deployment and service changes. 
                        # This requires AWS credentials to generate the EKS token.
                        kubectl apply -n ${K8S_NAMESPACE} -f deployment.yaml
                        kubectl apply -n ${K8S_NAMESPACE} -f service.yaml

                        echo "Deployment complete. Current services:" 
                        kubectl get svc -n ${K8S_NAMESPACE}
                        """
                }
            }
        }
    }

    post {
        success {
            echo "Deployment successful! Application image: ${DOCKER_IMAGE}:latest"
        }
        failure {
            echo "Build or deployment failed! Check the logs for authentication errors."
        }
    }
} 
