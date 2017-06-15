#!/bin/sh
# List branches. User has option to list local branches and remote branches.
# Input: List local branches (y/n)
# Input: List remote branches (y/n)

LIST_LOCAL_BRANCHES=$1
LIST_REMOTE_BRANCHES=$2

if [[ $LIST_LOCAL_BRANCHES =~ [Yy] ]]; then
    echo LOCAL BRANCHES
    git branch
fi

if [[ $LIST_REMOTE_BRANCHES =~ [Yy] ]]; then
    git remote update origin --prune
    echo REMOTE BRANCHES
    git branch -r
fi



