#!/bin/sh
# Display name of current branch

echo Branch: `git branch | grep '\*' | cut -d ' ' -f2`
