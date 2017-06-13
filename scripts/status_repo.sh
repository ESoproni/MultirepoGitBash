#!/bin/bash 
# Display status for all repos

printf "\n"
# Update local references for remote branches
git fetch --all --prune --tags >/dev/null		
git status
