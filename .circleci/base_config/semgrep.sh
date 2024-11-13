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
    common_prefix="."
    # Check if there are any files
    if [ -z "$changed_files" ]; then
        echo "No changes"
    else
        echo "There are changes"
    fi
    # Convert the list into an array
    files=($changed_files)
    # If there is only one file, return its parent directory
    #if [ ${#files[@]} -eq 1 ]; then
    #    parent_dir=$(dirname "${files[0]}")
    #    echo "Common directory: $parent_dir"
    #    echo 'export common_directory=$parent_dir' >> $BASH_ENV
    #fi
    # Find the common parent directory
    #common_prefix="${files[0]}"
    #for file in "${files[@]:1}"; do
    #    while [[ $file != $common_prefix* ]]; do
    #        common_prefix=$(dirname "$common_prefix")
            # If we reach the root directory, return "."
    #        if [[ "$common_prefix" == "." || "$common_prefix" == "/" ]]; then
    #            echo "Common directory: ."
    #            echo 'export common_directory=.' >> $BASH_ENV
    #        fi
    #    done
    #done
    # Print and export the final common directory
    common_directory=$common_prefix
    echo "Common directory: $common_directory"
    if [ "$common_directory" = "." ]; then
        semgrep ci --baseline-commit=$(git merge-base development HEAD) --max-memory 3700 -j 5 || true
    else
        semgrep ci --baseline-commit=$(git merge-base development HEAD) --max-memory 3700 -j 5 --include=$common_directory/* || true
    fi
else
    if [ "$CIRCLE_BRANCH" == "development" ]; then
        echo "Running Full scan for branch: $CIRCLE_BRANCH"
        semgrep ci --max-memory 3700 -j 5 || true
    else
        echo "Skipping full scan for branches different to development."
    fi
fi
