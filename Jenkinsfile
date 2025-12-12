pipeline {
    agent any
    stages {
        stage("Code Checkout") {
            steps {
                git url: "https://github.com/Kowsik1406/guvi_project2", branch: "main"
            }
        }
        stage("Build Docker Image") {
            steps {
                sh 'docker build -t vikram140602/trend-app:latest .'
            }
        }
        stage("Push Docker Image") {
            steps {
                sh 'docker push vikram140602/trend-app:latest'
            }
        }
        stage("Deploy to EKS") {
            steps {
                sh 'kubectl apply -f app.yml'
            }
        }
    }
}
