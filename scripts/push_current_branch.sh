#!/bin/bash
# Pushing current branch to remote

CURRENT_BRANCH=`git branch | grep '\*' | cut -d ' ' -f2`

while true; do
    git status
    read -p "Are you sure you want to push $CURRENT_BRANCH?( (y/n)" answer
    case $answer in
        [Yy]* ) echo "Pushing $CURRENT_BRANCH to remote"; git push origin HEAD; break;;
        [Nn]* ) echo "Push aborted"; break;;
        * ) echo "Invalid input. ABORTING PUSH OF  $CURRENT_BRANCH"; continue;;
    esac
done
