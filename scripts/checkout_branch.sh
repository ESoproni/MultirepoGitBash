#!/bin/bash
# Check out branch
# Input: branch name to check out

# Update local references for remote branches
checkout_branch() {
  git fetch --all --prune --tags >/dev/null

  if [ "$1" = "" ] ; then
      echo -e "${COLOR_RED}>>> No branch name entered${COLOR_RESET}"
	  return 1
  else
      echo \>\>\> Checking out branch "$1"
      git checkout $1
  fi
}

checkout_branch