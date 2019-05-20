#!/bin/bash
# Input branch name to merge to develop branch

# Update local references for remote branches
git fetch --all --prune --tags >/dev/null

git checkout develop

#If not on develop branch, don't merge
ON_DEVELOP=`git branch | grep "*"`
if [[ -z $ON_DEVELOP ]]; then
    echo ">>> not in develop branch"
    exit
fi

BRANCH_TO_MERGE=$1
#Pull latest changes
PULL_STATUS=`git pull`

if [[ $PULL_STATUS = "Already up-to-date." ]]; then
    echo Merging $BRANCH_TO_MERGE
    MERGE_FAILED=`git merge $BRANCH_TO_MERGE --no-ff | grep "Automatic merge failed"`
    if [[ -z "$MERGE_FAILED" ]]; then
        echo "Merge went well. Committing."
        git commit -q
    else
        echo $MERGE_FAILED
    fi
else
    echo !!! Local repo is not up to date with remote. Pull changes from remote before merging!
fi

