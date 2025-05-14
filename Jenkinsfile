pipeline {
    agent any

    tools {
        jdk 'jdk17'
        terraform 'terraform'
    }

    environment {
        // Make sure this is defined in Jenkins credentials if needed
        SONARQUBE_ENV = credentials('Sonar-token')
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout from Git') {
            steps {
                git branch: 'main', url: 'https://github.com/JaiBhargav/TERRAFORM-JENKINS-CICD'
            }
        }

        stage('Terraform Version') {
            steps {
                sh 'terraform --version'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    script {
                        def scannerHome = tool name: 'sonar-scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                        sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectName=Terraform -Dsonar.projectKey=Terraform"
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Trivy FS Scan') {
            steps {
                sh 'trivy fs . > trivyfs.txt'
            }
        }

        stage('Executable Permission to userdata') {
            steps {
                sh 'chmod +x website.sh'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan'
            }
        }

        stage('Terraform Apply') {
            steps {
                // Replace `action` with an actual variable or string, if you mean "apply"
                sh 'terraform apply --auto-approve'
            }
        }
    }
}
