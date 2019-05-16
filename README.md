# MultirepoGitBash
Some scripts to execute git commands on multiple repositories

Download this project to your local hard drive.
On the first run, you will be able to set the path of the directory that holds the Git repositories. This path will be stored in a file called REPOROOTPATH.

With this utility you can run the same command/query on all your repositories. 
List of commands/queries:
current_branch - lists the branch currently checked out
status_repo - executes the git status command showing non-staged changes
pull_repo - pulls the current or selected branch to pull from the remote
pull_branches_behind - pulls all the branches that are beind the remote
checkout_branch - checks out/switches to the selected branch
remove_gone_branches - removes the local branches that are no longer on the remote
