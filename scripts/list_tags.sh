#!/bin/sh
# Lists all tags. User has option to list local tags, remote tags, peeled tags
# Input: List local tags (y/n)
# Input: List remote tags (y/n)
# Input: List peeled remote tags (y/n)

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
