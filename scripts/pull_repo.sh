#!/bin/bash 
# Pulls all changes for the repo
# Input: branch name if you want that branch to be updated with the remote changes
#        ! if you are on another branch that has non-committed changes, the pull operation will fail
#        To update the current branch, don't submit a branch name

# Update local references for remote branches
git fetch --all --prune --tags >/dev/null

CURRENT_BRANCH=`git branch | grep '\*' | cut -d ' ' -f2`		

if [ "$1" = "" ] || [ "$1" = "$CURRENT_BRANCH" ] ; then
	echo \>\>\> On branch $CURRENT_BRANCH. Pulling latest changes.
	git pull
else
	echo \>\>\> On branch $CURRENT_BRANCH. Checking out branch "$1"
	
	if [[ `git checkout $1` ]]; then
		git pull
		echo \>\>\>Switching back to previously checked out branch
		git checkout $CURRENT_BRANCH
	else
		echo \>\>\>Branch $1 does not exist in this repository
		echo \!\!\! Check out and pull preferred branch manually
	fi
fi
