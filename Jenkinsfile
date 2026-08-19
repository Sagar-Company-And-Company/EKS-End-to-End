pipeline {
    agent any

    environment {
        REPO = 'Sagar-Company-And-Company/EKS-End-to-End'
        SOURCE = 'PR-test'
        TARGET = 'dev'
    }

    stages {

        stage('Test') {
            steps {
                echo 'Jenkins CI test successful'
            }
        }

        stage('Create PR') {
            steps {
                withCredentials([
                    string(
                        credentialsId: 'github-creds',
                        variable: 'GH_TOKEN'
                    )
                ]) {
                    sh '''
                        export GH_TOKEN="$GH_TOKEN"

                        PR=$(gh pr list \
                          --repo "$REPO" \
                          --head "$SOURCE" \
                          --base "$TARGET" \
                          --state open \
                          --json number \
                          --jq '.[0].number')

                        if [ -z "$PR" ]; then
                            echo "Creating PR..."

                            gh pr create \
                              --repo "$REPO" \
                              --head "$SOURCE" \
                              --base "$TARGET" \
                              --title "Test PR: $SOURCE to $TARGET" \
                              --body "Automatically created by Jenkins."
                        else
                            echo "PR already exists: #$PR"
                        fi
                    '''
                }
            }
        }

        stage('Merge PR') {
            steps {
                withCredentials([
                    string(
                        credentialsId: 'github-pr-token',
                        variable: 'GH_TOKEN'
                    )
                ]) {
                    sh '''
                        export GH_TOKEN="$GH_TOKEN"

                        PR=$(gh pr list \
                          --repo "$REPO" \
                          --head "$SOURCE" \
                          --base "$TARGET" \
                          --state open \
                          --json number \
                          --jq '.[0].number')

                        echo "PR Number: $PR"

                        sleep 10

                        gh pr merge "$PR" \
                          --repo "$REPO" \
                          --merge \
                          --delete-branch=false
                    '''
                }
            }
        }
    }
}
