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
                sh 'docker login -u vikram140602 -p $pswd'     
                sh 'docker push vikram140602/trend-app:latest'
            }
        }
        stage("Deploy to EKS") {
            steps {
              script {
               withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS']]) {
                sh 'aws eks update-kubeconfig --region ap-south-1 --name trend'
                sh 'kubectl apply -f app.yml'
                sh 'kubectl get svc'
               }
              }
            }
        }
    }
}
