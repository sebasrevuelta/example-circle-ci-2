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
        
    # Fetch the changed files from the last commit
    relevant_commit=$(git merge-base development HEAD)
    changed_files=$(git diff --name-only "$relevant_commit" HEAD)
    echo "$changed_files"

    # Check if there are any files
    if [ -z "$changed_files" ]; then
        echo "No changes"
    else 
        # Initialize the common prefix with the first file's directory
        common_prefix=$(dirname "$(echo "$changed_files" | head -n 1)")
    
        # Iterate through the changed files to find the common prefix
        for file in $changed_files; do
            while [ "${file#"$common_prefix"}" = "$file" ]; do
                common_prefix=$(dirname "$common_prefix")
                # If we reach the root directory, return "."
                if [ "$common_prefix" = "." ] || [ "$common_prefix" = "/" ]; then
                    echo "Common directory: ."
                    break
                fi
            done
        done
        # Print and export the final common directory
        common_directory=$common_prefix
        echo "Common directory: $common_directory"
        if [ "$common_directory" = "." ]; then
            semgrep ci --baseline-commit=$(git merge-base development HEAD) --max-memory 3700 -j 5 || true
        else
            # Loop until the root directory is reached
            while [ "$common_directory" != "/" ]; do
                echo "Searching in $common_directory..."
            
                # Check for files matching the patterns
                if find "$common_directory" -type f \( -name '*-lock.yaml' -o -name '*-lock.json' \) | grep -q .; then
                    echo "A file matching *-lock.yaml or *-lock.json was found in $common_directory."
                    break
                fi
            
                # Move up to the parent directory
                common_directory=$(dirname "$common_directory")
            done
            echo "Directory to scan: $common_directory"
            semgrep ci --baseline-commit=$(git merge-base development HEAD) --max-memory 3700 -j 5 --subdir=A || true
        fi
    fi
fi
