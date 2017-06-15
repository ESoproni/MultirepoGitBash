#!/bin/sh
# Removes all tags both locally and on the server, which start with the input string
# Input: string representing the beginning of the name of the tags to be removed

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
