pipeline {
    agent any

    parameters {
        string(name: 'customersService', defaultValue: 'latest', description: 'Tag for customers-service')
        string(name: 'visitsService',   defaultValue: 'latest', description: 'Tag for visits-service')
        string(name: 'vetsService',     defaultValue: 'latest', description: 'Tag for vets-service')
        string(name: 'apiGateway',      defaultValue: 'latest', description: 'Tag for api-gateway')
    }

    environment {
        DOCKERHUB_CRED = 'dockerhub-credentials'
        CHART_PATH     = '.'
    }

    stages {
        stage('DockerHub Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: env.DOCKERHUB_CRED,
                    usernameVariable: 'DOCKERHUB_USER',
                    passwordVariable: 'DOCKERHUB_PASS'
                )]) {
                    sh 'echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin'
                }
            }
        }

        stage('Helm Deploy') {
            steps {
                script {
                    def targetNs    = "review-${env.BUILD_NUMBER}"
                    def releaseName = "petclinic-${targetNs}"

                    sh """
                        helm upgrade ${releaseName} ${env.CHART_PATH} \\
                          --install \\
                          --namespace ${targetNs} \\
                          --create-namespace \\
                          -f ${env.CHART_PATH}/environments/values-dev.yaml \\
                          --set namespace=${targetNs} \\
                          --set image.overrideTags.customers-service=${params.customersService} \\
                          --set image.overrideTags.visits-service=${params.visitsService} \\
                          --set image.overrideTags.vets-service=${params.vetsService} \\
                          --set image.overrideTags.api-gateway=${params.apiGateway} \\
                          --atomic \\
                          --timeout 5m
                    """
                }
            }
        }

        stage('Add description') {
            steps {
                script {
                    def buildNum = currentBuild.number
                    def deleteUrl = "https://jenkins.roger.works/generic-webhook-trigger/invoke?token=delete-token&BUILD_NUMBER=${buildNum}"
                    currentBuild.description = "[Click here to delete this review-#${buildNum}](${deleteUrl})"
                }
            }
        }
    }

    post {
        success { echo "✅ Deployed to namespace review-${env.BUILD_NUMBER}" }
        failure { echo "❌ Deploy failed." }
    }
}