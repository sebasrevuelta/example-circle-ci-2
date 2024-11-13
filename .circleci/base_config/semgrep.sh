#!/bin/sh
echo 'export SEMGREP_APP_TOKEN=$SEMGREP_APP_TOKEN' >> $BASH_ENV
echo 'export SEMGREP_COMMIT=$CIRCLE_SHA1' >> $BASH_ENV
echo 'export SEMGREP_JOB_URL=$CIRCLE_BUILD_URL' >> $BASH_ENV
PR_NUMBER=$(echo "$CIRCLE_PULL_REQUEST" | awk -F '/' '{print $NF}' )
if [ -n "$PR_NUMBER" ]; then 
    echo 'export SEMGREP_BASELINE_REF = "origin/<< pipeline.parameters.master_branch >>"' >> $BASH_ENV
    echo "Pull Request Number: $PR_NUMBER"
    echo 'export SEMGREP_PR_ID=$PR_NUMBER' >> $BASH_ENV
    git fetch origin "+refs/heads/*:refs/remotes/origin/*"

    ## Get the subfolders to scan
    echo "Fetching list of changed files..."
    changed_files=$(git diff --name-only FETCH_HEAD)
    echo "Changed files:"
    echo "$changed_files"
    common_directory = "."
    # Check if there are any files
    if [ -z "$changed_files" ]; then
        common_directory = "."
        echo "Common directory: $common_directory"
    fi

    semgrep ci --baseline-commit=$(git merge-base development HEAD) --max-memory 3700 -j 5 --include="$common_directory" || true
else
    if [ "$CIRCLE_BRANCH" == "development" ]; then
        echo "Running Full scan for branch: $CIRCLE_BRANCH"
        semgrep ci --max-memory 3700 -j 5 || true
    else
        echo "Skipping full scan for branches different to development."
    fi
fi
