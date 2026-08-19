pipeline {
    agent any

    environment {
        GITHUB_REPO = 'Sagar-Company-And-Company/EKS-End-to-End'
        SOURCE_BRANCH = 'PR-test'
        TARGET_BRANCH = 'dev'
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('CI Test') {
            steps {
                echo "Running CI..."

                sh '''
                    echo "Simple CI test"
                    echo "CI PASSED"
                '''
            }
        }

        stage('Create PR') {
            steps {
                withCredentials([string(
                    credentialsId: 'github-creds',
                    variable: 'GITHUB_TOKEN'
                )]) {

                    sh '''
                        echo "Creating PR PR-test -> dev"

                        curl -s -X POST \
                          -H "Authorization: Bearer ${GITHUB_TOKEN}" \
                          -H "Accept: application/vnd.github+json" \
                          https://api.github.com/repos/${GITHUB_REPO}/pulls \
                          -d '{
                            "title":"Automatic PR: PR-test -> dev",
                            "head":"PR-test",
                            "base":"dev",
                            "body":"Automatically created by Jenkins after successful CI."
                          }'
                    '''
                }
            }
        }

        stage('Approve and Merge PR') {
            steps {
                withCredentials([string(
                    credentialsId: 'github-creds',
                    variable: 'GITHUB_TOKEN'
                )]) {

                    sh '''
                        echo "Finding PR..."

                        PR_NUMBER=$(curl -s \
                          -H "Authorization: Bearer ${GITHUB_TOKEN}" \
                          -H "Accept: application/vnd.github+json" \
                          "https://api.github.com/repos/${GITHUB_REPO}/pulls?head=Sagar-Company-And-Company:${SOURCE_BRANCH}&base=${TARGET_BRANCH}" \
                          | grep -m1 '"number"' \
                          | grep -o '[0-9]*')

                        echo "PR Number: ${PR_NUMBER}"

                        echo "Approving PR..."

                        curl -s -X POST \
                          -H "Authorization: Bearer ${GITHUB_TOKEN}" \
                          -H "Accept: application/vnd.github+json" \
                          "https://api.github.com/repos/${GITHUB_REPO}/pulls/${PR_NUMBER}/reviews" \
                          -d '{
                            "event":"APPROVE",
                            "body":"Automatically approved after successful Jenkins CI."
                          }'

                        echo "Enabling auto-merge..."

                        curl -s -X PUT \
                          -H "Authorization: Bearer ${GITHUB_TOKEN}" \
                          -H "Accept: application/vnd.github+json" \
                          "https://api.github.com/repos/${GITHUB_REPO}/pulls/${PR_NUMBER}/auto-merge" \
                          -d '{
                            "merge_method":"merge"
                          }'
                    '''
                }
            }
        }
    }
}
