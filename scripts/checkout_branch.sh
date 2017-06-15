#!/bin/bash
# Check out branch
# Input: branch name to check out

# Update local references for remote branches
git fetch --all --prune --tags >/dev/null

if [ "$1" = "" ] ; then
    echo \>\>\> No branch name entered
else
    echo \>\>\> Checking out branch "$1"
    git checkout $1
fi
