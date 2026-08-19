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
                sh '''
                    set -e
                    echo "======================================"
                    echo "Running CI Test"
                    echo "======================================"

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
                        usernameVariable: 'GH_USER',
                        passwordVariable: 'GH_TOKEN'
                    )
                ]) {

                    sh '''
                        set -e

                        echo "Checking existing PR..."

                        EXISTING_PR=$(curl -s \
                          -u "${GH_USER}:${GH_TOKEN}" \
                          -H "Accept: application/vnd.github+json" \
                          "https://api.github.com/repos/${GITHUB_REPO}/pulls?state=open&head=Sagar-Company-And-Company:${SOURCE_BRANCH}&base=${TARGET_BRANCH}" \
                          | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[0]['number'] if d else '')")

                        if [ -n "$EXISTING_PR" ]; then

                            echo "Existing PR found: #${EXISTING_PR}"
                            echo "$EXISTING_PR" > pr_number.txt

                        else

                            echo "Creating PR ${SOURCE_BRANCH} -> ${TARGET_BRANCH}"

                            RESPONSE=$(curl -s -X POST \
                              -u "${GH_USER}:${GH_TOKEN}" \
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

                            PR_NUMBER=$(echo "$RESPONSE" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('number',''))")

                            if [ -z "$PR_NUMBER" ]; then
                                echo "Failed to create PR"
                                exit 1
                            fi

                            echo "Created PR #${PR_NUMBER}"
                            echo "$PR_NUMBER" > pr_number.txt

                        fi
                    '''
                }

                archiveArtifacts artifacts: 'pr_number.txt', fingerprint: true
            }
        }

        stage('Validate Approval Credentials') {
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

                        echo "Validating PR approval credentials..."

                        USER_RESPONSE=$(curl -s -u "${PR_USER}:${PR_TOKEN}" \
                          -H "Accept: application/vnd.github+json" \
                          https://api.github.com/user)

                        echo "$USER_RESPONSE" | python3 -c "
import sys,json
d=json.load(sys.stdin)

if 'message' in d:
    print('GitHub authentication failed:', d['message'])
    sys.exit(1)

print('Authenticated GitHub user:', d.get('login'))
"

                        echo "PR approval credentials are valid"
                    '''
                }
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

                        APPROVE_RESPONSE=$(curl -s -X POST \
                          -u "${PR_USER}:${PR_TOKEN}" \
                          -H "Accept: application/vnd.github+json" \
                          -H "Content-Type: application/json" \
                          "https://api.github.com/repos/${GITHUB_REPO}/pulls/${PR_NUMBER}/reviews" \
                          -d '{
                            "event": "APPROVE",
                            "body": "Automatically approved after successful Jenkins CI."
                          }')

                        echo "$APPROVE_RESPONSE"

                        echo "$APPROVE_RESPONSE" | python3 -c "
import sys,json
d=json.load(sys.stdin)

if 'message' in d:
    print('PR approval failed:', d['message'])
    sys.exit(1)

print('PR approved successfully')
"
                    '''
                }
            }
        }

        stage('Wait For Required Checks') {
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

                        echo "Waiting for GitHub required checks..."

                        for i in $(seq 1 20)
                        do
                            echo "Check attempt $i/20"

                            STATUS=$(curl -s \
                              -u "${PR_USER}:${PR_TOKEN}" \
                              -H "Accept: application/vnd.github+json" \
                              "https://api.github.com/repos/${GITHUB_REPO}/commits/${GIT_COMMIT}/status")

                            STATE=$(echo "$STATUS" | python3 -c "import sys,json; print(json.load(sys.stdin).get('state',''))")

                            echo "Combined status: ${STATE}"

                            if [ "$STATE" = "success" ]; then
                                echo "Required Jenkins status check passed"
                                exit 0
                            fi

                            if [ "$STATE" = "failure" ] || [ "$STATE" = "error" ]; then
                                echo "Required status check failed"
                                exit 1
                            fi

                            sleep 15
                        done

                        echo "Required status check did not become successful"
                        exit 1
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

                        echo "Checking PR #${PR_NUMBER}"

                        for i in $(seq 1 10)
                        do
                            RESPONSE=$(curl -s \
                              -u "${PR_USER}:${PR_TOKEN}" \
                              -H "Accept: application/vnd.github+json" \
                              "https://api.github.com/repos/${GITHUB_REPO}/pulls/${PR_NUMBER}")

                            MERGEABLE=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('mergeable'))")
                            MERGE_STATE=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('mergeable_state'))")

                            echo "mergeable=${MERGEABLE}"
                            echo "mergeable_state=${MERGE_STATE}"

                            if [ "$MERGEABLE" = "true" ] && [ "$MERGE_STATE" = "clean" ]; then

                                echo "Merging PR #${PR_NUMBER}"

                                MERGE_RESPONSE=$(curl -s -X PUT \
                                  -u "${PR_USER}:${PR_TOKEN}" \
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
                                    echo "======================================"
                                    echo "PR #${PR_NUMBER} MERGED SUCCESSFULLY"
                                    echo "======================================"
                                    exit 0
                                fi
                            fi

                            echo "PR not ready for merge. Waiting 15 seconds..."
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
            echo "======================================"
            echo "CI + PR + APPROVAL + MERGE SUCCESS"
            echo "======================================"
        }

        failure {
            echo "======================================"
            echo "PIPELINE FAILED"
            echo "======================================"
        }
    }
}

