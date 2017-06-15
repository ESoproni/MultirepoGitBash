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

$LIST_LOCAL_TAGS
$LIST_REMOTE_TAGS
$SHOW_PEELED_TAGS
$LIST_LOCAL_BRANCHES
$LIST_REMOTE_BRANCHES
$ROOTPATH

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
    echo "=== ERROR === Directory set in $ROOTPATH is not a valid directory. The directory must be on the first line of the file!"
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

BASEDIR=$(dirname "$0")
cd "$BASEDIR"
get_repos_root_path
export SCRIPT_ABS_PATH="$BASEDIR/scripts"
cd "$ROOTPATH"

loop_dirs() {
    for D in *; do
        if [ -d  "${D}" ]; then
            cd "${D}"

            "$SCRIPT_ABS_PATH"/in_git_repo.sh
            if [  $? -eq 0 ]; then
               cd ..
               continue
            fi

            echo -------
            echo In directory `pwd`

            "$SCRIPT_ABS_PATH"/$1 $2 $3 $4

            cd ..
        fi
    done
}

if  [ ! -d "$SCRIPT_ABS_PATH" ]; then
    echo $SCRIPT_ABS_PATH is not a valid path
    echo Path to the directory containing the scripts for multirepohelper.sh must be set in multirepohelper.sh SCRIPT_ABS_PATH
    exit 0
fi

while true; do
    printf "\n============================\nROOTPATH=%b\n============================\n\n" "$ROOTPATH"
    PS3=$'\nSelect what to run for all repos:\n'
    options=("current branch" "status" "fetch" "pull [...]" "pull branches that are behind" "checkout branch [...]" "remove local branches that link to removed branches on server" "prune local tags" "list tags [...]" "list branches [...]" "merge to current branch from develop" "merge branch to develop [...]" "push current branch" "list remotes")

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
            9 ) SELECTED="list_tags"; collect_list_tags_params; param_1=$LIST_LOCAL_TAGS param_2=$LIST_REMOTE_TAGS; param_3=$SHOW_PEELED_TAGS;;
            10 ) SELECTED="list_branches"; collect_list_branches_params; param_1=$LIST_LOCAL_BRANCHES param_2=$LIST_REMOTE_BRANCHES;;
            11 ) SELECTED="merge_from_develop";;
            12 ) SELECTED="merge_branch_to_develop"; read -p "=== Input name of branch to merge to develop. (Result will NOT be pushed!) " param_1;;
            13 ) SELECTED="push_current_branch";;
            14 ) SELECTED="list_remotes";;
            $(( ${#options[@]}+1 )) ) echo "Goodbye!"; exit 1;;
            *) echo "Invalid option. Try another one.";continue;;
        esac

        loop_dirs $SELECTED.sh $param_1 $param_2 $param_3
        param_1=""
        param_2=""
        param_3=""
        break;
    done
done
