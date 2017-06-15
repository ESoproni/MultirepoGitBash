#!/bin/sh
# Remove all local branches where the referenced remote branch has been removed

git fetch --all --prune
git branch -vv | gawk '{print $1,$4}' | grep 'gone]' | gawk '{print $1}' | xargs git branch -D
