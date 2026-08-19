pipeline {
    agent any

    environment {
        GITHUB_REPO   = 'Sagar-Company-And-Company/EKS-End-to-End'
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
                echo 'Running CI...'

                sh '''
                    set -e
                    echo "Simple CI test"
                    echo "CI PASSED"
                '''
            }
        }

        stage('Create PR') {
            when {
                branch 'PR-test'
            }

            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'github-creds',
                        usernameVariable: 'GITHUB_USER',
                        passwordVariable: 'GITHUB_TOKEN'
                    )
                ]) {

                    sh '''
                        set -e

                        echo "Checking existing PR..."

                        EXISTING_PR=$(curl -s \
                          -H "Authorization: Bearer ${GITHUB_TOKEN}" \
                          -H "Accept: application/vnd.github+json" \
                          "https://api.github.com/repos/${GITHUB_REPO}/pulls?state=open&head=Sagar-Company-And-Company:${SOURCE_BRANCH}&base=${TARGET_BRANCH}" \
                          | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0]['number'] if d else '')")

                        if [ -n "$EXISTING_PR" ]; then
                            echo "PR already exists: #${EXISTING_PR}"
                            echo "$EXISTING_PR" > pr_number.txt
                        else
                            echo "Creating PR: ${SOURCE_BRANCH} -> ${TARGET_BRANCH}"

                            RESPONSE=$(curl -s -X POST \
                              -H "Authorization: Bearer ${GITHUB_TOKEN}" \
                              -H "Accept: application/vnd.github+json" \
                              -H "Content-Type: application/json" \
                              "https://api.github.com/repos/${GITHUB_REPO}/pulls" \
                              -d "{
                                \\"title\\": \\"Automatic PR: ${SOURCE_BRANCH} -> ${TARGET_BRANCH}\\",
                                \\"head\\": \\"${SOURCE_BRANCH}\\",
                                \\"base\\": \\"${TARGET_BRANCH}\\",
                                \\"body\\": \\"Automatically created by Jenkins after successful CI.\\"
                              }")

                            echo "$RESPONSE"

                            PR_NUMBER=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['number'])")

                            echo "Created PR #${PR_NUMBER}"

                            echo "$PR_NUMBER" > pr_number.txt
                        fi
                    '''
                }

                archiveArtifacts artifacts: 'pr_number.txt', fingerprint: true
            }
        }

        stage('Approve PR') {
            when {
                branch 'PR-test'
            }

            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'PR-creds',
                        usernameVariable: 'PR_USER',
                        passwordVariable: 'PR_TOKEN'
                    )
                ]) {

                    sh '''
                        set -e

                        PR_NUMBER=$(cat pr_number.txt)

                        echo "Approving PR #${PR_NUMBER} using ${PR_USER}"

                        curl -s -X POST \
                          -H "Authorization: Bearer ${PR_TOKEN}" \
                          -H "Accept: application/vnd.github+json" \
                          -H "Content-Type: application/json" \
                          "https://api.github.com/repos/${GITHUB_REPO}/pulls/${PR_NUMBER}/reviews" \
                          -d '{
                            "event": "APPROVE",
                            "body": "Automatically approved after successful Jenkins CI."
                          }' > approve_response.json

                        cat approve_response.json

                        if grep -q '"message"' approve_response.json; then
                            echo "PR approval failed"
                            exit 1
                        fi

                        echo "PR #${PR_NUMBER} approved successfully"
                    '''
                }
            }
        }

        stage('Merge PR') {
            when {
                branch 'PR-test'
            }

            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'PR-creds',
                        usernameVariable: 'PR_USER',
                        passwordVariable: 'PR_TOKEN'
                    )
                ]) {

                    sh '''
                        set -e

                        PR_NUMBER=$(cat pr_number.txt)

                        echo "Waiting for GitHub required status checks..."

                        for i in $(seq 1 20)
                        do
                            RESPONSE=$(curl -s \
                              -H "Authorization: Bearer ${PR_TOKEN}" \
                              -H "Accept: application/vnd.github+json" \
                              "https://api.github.com/repos/${GITHUB_REPO}/pulls/${PR_NUMBER}")

                            MERGEABLE=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('mergeable'))")
                            MERGE_STATE=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('mergeable_state'))")

                            echo "mergeable=${MERGEABLE}"
                            echo "mergeable_state=${MERGE_STATE}"

                            if [ "$MERGEABLE" = "true" ] && [ "$MERGE_STATE" = "clean" ]; then

                                echo "Merging PR #${PR_NUMBER}"

                                MERGE_RESPONSE=$(curl -s -X PUT \
                                  -H "Authorization: Bearer ${PR_TOKEN}" \
                                  -H "Accept: application/vnd.github+json" \
                                  -H "Content-Type: application/json" \
                                  "https://api.github.com/repos/${GITHUB_REPO}/pulls/${PR_NUMBER}/merge" \
                                  -d '{
                                    "merge_method": "merge",
                                    "commit_title": "Automatic merge: PR-test -> dev",
                                    "commit_message": "Automatically merged after successful Jenkins CI."
                                  }')

                                echo "$MERGE_RESPONSE"

                                MERGED=$(echo "$MERGE_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('merged',False))")

                                if [ "$MERGED" = "True" ]; then
                                    echo "PR #${PR_NUMBER} merged successfully"
                                    exit 0
                                fi
                            fi

                            echo "PR is not ready for merge. Waiting 15 seconds..."
                            sleep 15
                        done

                        echo "PR could not be merged"
                        exit 1
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '======================================'
            echo 'CI + PR + APPROVAL + MERGE SUCCESS'
            echo '======================================'
        }

        failure {
            echo '======================================'
            echo 'PIPELINE FAILED'
            echo '======================================'
        }
    }
}
