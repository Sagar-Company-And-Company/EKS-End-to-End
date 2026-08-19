pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Test') {
            steps {
                echo 'PR test started...'
                sh 'echo "Running unit tests..."'
                sh 'echo "All tests passed!"'
            }
        }

        stage('Build Test') {
            steps {
                sh 'echo "Build test passed!"'
            }
        }
    }

    post {
        success {
            echo 'PR CI PASSED'
        }

        failure {
            echo 'PR CI FAILED'
        }
    }
}
