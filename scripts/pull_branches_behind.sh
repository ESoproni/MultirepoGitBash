#!/bin/bash 
# Pull all branches that are behind

git fetch --all --prune
git branch -vv | gawk '{print $1,$4}' | grep 'behind]' | gawk '{print $1}' | xargs git pull origin