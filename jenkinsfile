pipeline {
    agent any

    environment {
        // Change these as needed
        DOCKER_REGISTRY = "docker.io"
        DOCKER_REPO     = "praveensise/project-2"
        APP_NAME        = "project-2"
        KUBE_NAMESPACE  = "default"
    }

    triggers {
        // Optional: in addition to webhook, poll SCM every 5 mins
        // pollSCM('H/5 * * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo "Building application..."
                // Example for Maven/Node/etc. Replace with your actual build.
                // sh 'mvn clean package'
                // sh 'npm install && npm test'
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    def imageTag = "${env.BUILD_NUMBER}"
                    env.IMAGE = "${DOCKER_REPO}:${imageTag}"
                }
                sh '''
                  echo "Building Docker image ${IMAGE}"
                  docker build -t ${IMAGE} .
                '''
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                      echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin ${DOCKER_REGISTRY}
                      docker push ${IMAGE}
                      docker logout ${DOCKER_REGISTRY}
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo "Deploying to Kubernetes..."

                // Option 1: use kubectl set image on existing deployment
                sh '''
                  kubectl -n ${KUBE_NAMESPACE} set image deployment/${APP_NAME} \
                    ${APP_NAME}=${IMAGE} --record
                '''

                // Option 2 (alternative): apply manifests in repo
                // sh 'kubectl apply -f k8s/'
            }
        }
    }

    post {
        success {
            echo "Deployment successful!"
        }
        failure {
            echo "Build or deployment failed."
        }
    }
}
