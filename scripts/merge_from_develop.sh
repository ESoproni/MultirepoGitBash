#!/bin/bash 
# Merges changes from develop to current branch

# Update local references for remote branches
git fetch --all --prune --tags >/dev/null

#If in develop branch, don't merge
CURRENT_BRANCH=`git branch | grep '\*' | cut -d ' ' -f2`
if [[ $CURRENT_BRANCH = "develop" ]]; then
	exit
fi

#If there is no develop branch, don't merge
DEVELOP_EXISTS=`git branch -r | grep "origin/develop"`
if [[ -z $DEVELOP_EXISTS ]]; then
	echo ">>> origin/develop does not exist"
	exit
fi

#Pull latest changes
PULL_STATUS=`git pull`

if [[ $PULL_STATUS = "Already up-to-date." ]]; then
	MERGE_FAILED=`git merge origin/develop | grep "Automatic merge failed"`
	if [[ -z "$MERGE_FAILED" ]]; then
		git commit -q
	else
		echo $MERGE_FAILED 		
	fi	
else
	echo !!! Local repo is not up to date with remote. Pull changes from remote before merging!
fi
