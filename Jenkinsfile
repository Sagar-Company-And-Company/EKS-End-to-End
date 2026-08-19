pipeline {
    agent any

    stages {

        stage('Test') {
            steps {
                echo '================================'
                echo 'PR PIPELINE TEST STARTED'
                echo '================================'

                sh 'echo "Hello from Jenkins PR CI"'
                sh 'echo "Running test..."'
                sh 'echo "TEST PASSED"'
            }
        }

        stage('Build Test') {
            steps {
                echo '================================'
                echo 'BUILD TEST'
                echo '================================'

                sh 'echo "Build successful"'
            }
        }
    }

    post {
        success {
            echo 'PR CI SUCCESS'
        }

        failure {
            echo 'PR CI FAILED'
        }
    }
}
