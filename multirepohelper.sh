#!/bin/sh
# Git helper to run scripts for multiple Git repos checked out to subdirectories within a common directory
# ROOT
#   |-- GitRepo1
#   |     |--.git
#   |
#   |-- GitRepo2
#   |     |--.git
#   |
#   |-- GitRepo3
#   |     |--.git
#   |
#
# The ROOT directory path in the example above will be stored in a file called REPOROOTPATH.
# If the file doesn't exist, it will be created when you run this script.
#

# Set color codes
COLOR_RESET='\e[0m'
COLOR_RED='\e[0;31m'
COLOR_GREEN='\e[0;32m'
COLOR_ORANGE='\e[0;33m'
COLOR_BLUE='\e[0;34m'
COLOR_PURPLE='\e[0;35m'
COLOR_CYAN='\e[0;36m'
COLOR_LIGHTGRAY='\e[0;37m'
COLOR_YELLOW='\e[1;33m'
COLOR_WHITE='\e[1;37m'

$LIST_LOCAL_TAGS
$LIST_REMOTE_TAGS
$SHOW_PEELED_TAGS
$LIST_LOCAL_BRANCHES
$LIST_REMOTE_BRANCHES
$ROOTPATH
			
# Updates local references for remote branches
# Input: branch name to check out
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

# Display name of current branch
current_branch() {
  CURRENT_BRANCH=`git branch | grep '\*' | cut -d ' ' -f2`
  echo -e "Branch: ${COLOR_CYAN}${CURRENT_BRANCH}${COLOR_RESET}"
}

# Execute a fetch including tags
# Remove branch references to branches that don't exist on the remote anymore branches
fetch_repo() {
  git fetch --all --prune --tags >/dev/null
}

# List branches. User has option to list local branches and remote branches.
# Input: List local branches (y/n)
# Input: List remote branches (y/n)
list_branches() {
	LIST_LOCAL_BRANCHES=$1
	LIST_REMOTE_BRANCHES=$2

	if [[ $LIST_LOCAL_BRANCHES =~ [Yy] ]]; then
			echo -e "${COLOR_YELLOW} LOCAL BRANCHES ${COLOR_RESET}"
			git branch
	fi

	if [[ $LIST_REMOTE_BRANCHES =~ [Yy] ]]; then
			git remote update origin --prune
			echo -e "${COLOR_YELLOW} REMOTE BRANCHES ${COLOR_RESET}"
			git branch -r
	fi
}

# List the remotes that the local repository is poiting to for fetch and push
list_remotes(){
	git remote -v
}


# Lists all tags. User has option to list local tags, remote tags, peeled tags
# Input: List local tags (y/n)
# Input: List remote tags (y/n)
# Input: List peeled remote tags (y/n)
list_tags() {
	LIST_LOCAL_TAGS=$1
	LIST_REMOTE_TAGS=$2
	SHOW_PEELED_TAGS=$3

	if [[ $LIST_LOCAL_TAGS =~ [Yy] ]]; then
			echo LOCAL TAGS
			git show-ref --tags
	fi

	if [[ $LIST_REMOTE_TAGS =~ [Yy] ]]; then
			echo REMOTE TAGS
			case $SHOW_PEELED_TAGS in
					[Yy]* ) git ls-remote --tags; break;;
					[Nn]* ) git ls-remote --tags --refs; break;;
					* ) echo wtf; break;;
			esac
	fi
}

# Updates local references for remote branches
# Input: branch name to merge to develop branch
merge_branch_to_develop() {
	git fetch --all --prune --tags >/dev/null

	git checkout develop

	#If not on develop branch, don't merge
	ON_DEVELOP=`git branch | grep "*"`
	if [[ -z $ON_DEVELOP ]]; then
		echo -e "${COLOR_RED}>>> not in develop branch${COLOR_RESET}"
		exit
	fi

	BRANCH_TO_MERGE=$1
	#Pull latest changes
	PULL_STATUS=`git pull`

	if [[ $PULL_STATUS = "Already up-to-date." ]]; then
		echo Merging $BRANCH_TO_MERGE
		MERGE_FAILED=`git merge $BRANCH_TO_MERGE --no-ff | grep "Automatic merge failed"`
		if [[ -z "$MERGE_FAILED" ]]; then
			echo -e "${COLOR_GREEN}Merge went well. Committing.${COLOR_RESET}"
			git commit -q
		else
			echo -e "${COLOR_RED}$MERGE_FAILED${COLOR_RESET}"
		fi
	else
		echo -e "${COLOR_RED}!!! Local repo is not up to date with remote. Pull changes from remote before merging!${COLOR_RESET}"
	fi
}

# Updates local references for remote branches
# Merges changes from develop to current branch
merge_from_develop() {
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
}			

# Remove all local tags that don't exist on remote (origin)
prune_local_tags() {
	git fetch --prune origin +refs/tags/*:refs/tags/*
}

# Pull all branches that are behind
pull_branches_behind() {
	git fetch --all --prune
	git branch -vv | gawk '{print $1,$4}' | grep 'behind]' | gawk '{print $1}' | xargs git pull origin
}


# Updates local references for remote branches
# Pulls all changes for the repo
# Input: branch name if you want that branch to be updated with the remote changes
#        ! if you are on another branch that has non-committed changes, the pull operation will fail
#        To update the current branch, don't submit a branch name
pull_repo() {
	git fetch --all --prune --tags >/dev/null

	CURRENT_BRANCH=`git branch | grep '\*' | cut -d ' ' -f2`

	if [ "$1" = "" ] || [ "$1" = "$CURRENT_BRANCH" ] ; then
		echo -e "${COLOR_YELLOW}>>> On branch $CURRENT_BRANCH. Pulling latest changes.${COLOR_CYAN}"
#TODO: if git pull fails, display message but let the other repositories go on
		git pull
      echo -e "${COLOR_RESET}"
	else
		echo ">>> On branch ${CURRENT_BRANCH}. Checking out branch ${1}"

		if [[ `git checkout $1` ]]; then
			git pull
			echo ">>>Switching back to previously checked out branch"
			git checkout $CURRENT_BRANCH
		else
			echo ">>>Branch $1 does not exist in this repository"
			echo "!!! Check out and pull preferred branch manually"
		fi
	fi
}

# Pushing current branch to remote
push_current_branch() {
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
}


# Remove all local branches where the referenced remote branch has been removed
remove_gone_branches() {
	git fetch --all --prune
	git branch -vv | gawk '{print $1,$4}' | grep 'gone]' | gawk '{print $1}' | xargs git branch -D
}

# Remove named tag
# Input: tag name
remove_tag() {
	git push origin :$1
	git tag --delete $1
}

# Removes all tags both locally and on the server, which start with the input string
# Input: string representing the beginning of the name of the tags to be removed
remove_tags_starting_with() {
	echo Local tags starting with $1*
	echo ==============================
	git tag | sed -n "/^$1/p"
	echo ==============================

	while true; do
			read -p "Are you sure you want to delete both local and remote tags listed above? (y/n)  " delete_tags
			case $delete_tags in
					[Yy] ) git tag | sed -n "/^$1/p" | xargs -n 1 -I% sh -c 'git push origin :%; git tag --delete %'; break;;
					[Nn] ) echo No tags have been deleted; break;;
					* ) echo "Please answer y or n"; continue;;
			esac
	done
}

# Display status 
status_repo() {
	printf "\n"
	# Update local references for remote branches
	git fetch --all --prune --tags >/dev/null
	
   OUTPUT="$(git status)"
   if [[ $OUTPUT == *"nothing to commit, working tree clean" ]]; then
      echo -e "${COLOR_GREEN}${OUTPUT}${COLOR_RESET}"
   else
      git status
   fi
}

# Get current branch name
get_current_branch_name() {
   return `git branch | grep '\*' | cut -d ' ' -f2`
}

#Check if we are in a git repo directory
in_git_repo() {
  if [ -e ".git" ]; then
    return 1
  else
	return 0
  fi
}

get_repos_root_path() {

  ROOTPATHFILE="./REPOROOTPATH"
  if [ ! -f "$ROOTPATHFILE" ]; then
    echo $ROOTPATHFILE not found. Setting up $ROOTPATHFILE
    read -rp "Enter the path to your directory where you have your repositories: " reporootpath
    echo $reporootpath > "$ROOTPATHFILE"
  fi

  ROOTPATH=`head -n 1 $ROOTPATHFILE`

  if [ -z "$ROOTPATH" ]; then
    echo "=== ERROR === Root path not set"
    exit;
  elif [ ! -d "$ROOTPATH" ]; then
    echo "=== ERROR === Directory set in $ROOTPATH is not a valid directory. The directory must be on the first line of the REPOROOTPATH file!"
    exit;
  fi
}

remote_tags() {
    while true; do
        read -p "Show peeled tags as well? (y/n)  " show_peeled_tags
        case $show_peeled_tags in
            [YyNn]* ) SHOW_PEELED_TAGS=$show_peeled_tags; break;;
            * ) echo "Please answer yes or no"; continue;;
        esac
    done
}

collect_list_tags_params() {
    while true; do
        read -p "List local tags? (y/n)  " list_local_tags
        case $list_local_tags in
            [YyNn]* ) LIST_LOCAL_TAGS=$list_local_tags; break;;
            * ) echo "Please answer yes or no"; continue;;
        esac
    done

    while true; do
        read -p "List remote tags? (y/n)  " list_remote_tags
        LIST_REMOTE_TAGS=$list_remote_tags;
        case $list_remote_tags in
            [Yy]* ) remote_tags; break;;
            [Nn]* ) SHOW_PEELED_TAGS="n"; break;;
            * ) echo "Please answer yes or no"; continue;;
        esac
    done
}

collect_list_branches_params() {
    while true; do
        read -p "List local branches? (y/n)  " list_local_branches
        case $list_local_branches in
            [YyNn]* ) LIST_LOCAL_BRANCHES=$list_local_branches; break;;
            * ) echo "Please answer yes or no"; continue;;
        esac
    done

    while true; do
        read -p "List remote branches? (y/n)  " list_remote_branches
        LIST_REMOTE_BRANCHES=$list_remote_branches;
        case $list_remote_branches in
            [YyNn]* ) LIST_REMOTE_BRANCHES=$list_remote_branches; break;;
            * ) echo "Please answer yes or no"; continue;;
        esac
    done
}

BASEDIR=`dirname $(readlink -f "$0")`
echo $BASEDIR
cd "$BASEDIR"
get_repos_root_path
cd "$ROOTPATH"

loop_dirs() {
    for D in *; do
        if [ -d  "${D}" ]; then
            cd "${D}"

			in_git_repo
            if [  $? -eq 0 ]; then
               cd ..
               continue
            fi

            echo -------
            echo -e "In directory ${COLOR_CYAN}`pwd`${COLOR_RESET}"

			$1 $2 $3 $4            
			COMMAND_STATUS=$?
			if [ $COMMAND_STATUS -ne 0 ]; then
			   echo -e "${COLOR_RED}There was an error, command has not been executed for all repositories ${COLOR_RESET}"
			   return
			fi
            cd ..
        fi
    done
}

while true; do
    printf "\n============================\nROOTPATH=%b\n============================\n\n" "$ROOTPATH"
    PS3=$'\nSelect what to run for all repos:\n'
    options=("current branch" "status" "fetch" "pull [...]" "pull branches that are behind" "checkout branch [...]" "remove local branches that link to removed branches on server" "prune local tags" "remove tag" "remove tags starting with" "list tags [...]" "list branches [...]" "merge to current branch from develop" "merge branch to develop [...]" "push current branch" "list remotes")

    select opt in "${options[@]}" "Quit"
    do
    printf "\n============================\n\n"
        case "$REPLY" in
            1 ) SELECTED="current_branch";;
            2 ) SELECTED="status_repo";;
            3 ) SELECTED="fetch_repo";;
            4 ) SELECTED="pull_repo"; read -p "===Input name of branch to pull. If current branch, press ENTER. " param_1;;
            5 ) SELECTED="pull_branches_behind";;
            6 ) SELECTED="checkout_branch"; read -p "=== Input name of branch to checkout " param_1;;
            7 ) SELECTED="remove_gone_branches";;
            8 ) SELECTED="prune_local_tags";;
						9 ) SELECTED="remove_tag";;
						10 ) SELECTED="remove_tags_starting_with";;
            11 ) SELECTED="list_tags"; collect_list_tags_params; param_1=$LIST_LOCAL_TAGS param_2=$LIST_REMOTE_TAGS; param_3=$SHOW_PEELED_TAGS;;
            12 ) SELECTED="list_branches"; collect_list_branches_params; param_1=$LIST_LOCAL_BRANCHES param_2=$LIST_REMOTE_BRANCHES;;
            13 ) SELECTED="merge_from_develop";;
            14 ) SELECTED="merge_branch_to_develop"; read -p "=== Input name of branch to merge to develop. (Result will NOT be pushed!) " param_1;;
            15 ) SELECTED="push_current_branch";;
            16 ) SELECTED="list_remotes";;
            $(( ${#options[@]}+1 )) ) echo "Goodbye!"; exit 1;;
            *) echo "Invalid option. Try another one.";continue;;
        esac

		loop_dirs $SELECTED $param_1 $param_2 $param_3
		param_1=""
        param_2=""
        param_3=""		
        break;
    done
done
