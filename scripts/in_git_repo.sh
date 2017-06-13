#!/bin/sh
#Check if we are in a git repo directory

if [ -e ".git" ]; then
  exit 1
else
  exit 0
fi
