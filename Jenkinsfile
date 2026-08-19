pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('CI Test') {
            steps {
                echo "======================================"
                echo "Running CI for PR-test branch"
                echo "======================================"

                sh 'echo "Jenkins CI Test Passed"'
                sh 'git --version'
            }
        }

    }

    post {
        success {
            echo "CI PASSED"
        }

        failure {
            echo "CI FAILED"
        }
    }
}
