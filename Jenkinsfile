pipeline {
    agent any
    
        DOCKER_HUB_CREDENTIAL_ID = 'docker-hub'
        // MUST match the ID set in Jenkins Credentials (for your kubeconfig file)
        K8S_CONFIG_FILE          = 'k8s-config'

        DOCKER_HUB_REPO          = 'praveensise/ci-cd-app' 
        KUBERNETES_NAMESPACE     = 'default'
        APP_TAG                  = "${BUILD_NUMBER}" 
    }

    stages {
        stage('Checkout Code') {
            steps {
               
                echo 'Checking out source code...'
               
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                script {
                   
                    sh "docker build -t ${DOCKER_HUB_REPO}:${APP_TAG} ."
                   
                    sh "docker tag ${DOCKER_HUB_REPO}:${APP_TAG} ${DOCKER_HUB_REPO}:latest"
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                echo 'Logging into Docker Hub and pushing images...'
               
                withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDENTIAL_ID}",
                                                passwordVariable: 'DOCKER_PASSWORD',
                                                usernameVariable: 'DOCKER_USERNAME')]) {
                    script {
                        sh "docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}"
                        sh "docker push ${DOCKER_HUB_REPO}:${APP_TAG}"
                        sh "docker push ${DOCKER_HUB_REPO}:latest"
                        sh "docker logout"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo 'Deploying application to Kubernetes cluster...'
               
                withCredentials([file(credentialsId: "${K8S_CONFIG_FILE}", variable: 'KUBE_CONFIG_PATH')]) {
                    script {
                        // 1. Update the deployment manifest to use the new image tag (e.g., build number)
                        sh "sed -i 's|YOUR_DOCKER_HUB_USERNAME/ci-cd-app:latest|${DOCKER_HUB_REPO}:${APP_TAG}|g' k8s/deployment.yaml"

                        // 2. Apply the configuration using the secret kubeconfig file
                        sh "kubectl --kubeconfig=${KUBE_CONFIG_PATH} apply -f k8s/deployment.yaml -n ${KUBERNETES_NAMESPACE}"

                        // 3. Wait for the deployment to roll out successfully
                        echo "Waiting for deployment to be ready..."
                        sh "kubectl --kubeconfig=${KUBE_CONFIG_PATH} rollout status deployment/ci-cd-app-deployment --timeout=300s -n ${KUBERNETES_NAMESPACE}"

                        // 4. Print the LoadBalancer address for verification
                        echo "Deployment Complete. LoadBalancer IP/Hostname:"
                        sh "kubectl --kubeconfig=${KUBE_CONFIG_PATH} get svc ci-cd-app-service -n ${KUBERNETES_NAMESPACE}"
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finished. Check logs for deployment status.'
        }
        failure {
            echo 'CI/CD Pipeline FAILED. Review logs for errors in build, push, or deployment stages.'
        }
    }
}
