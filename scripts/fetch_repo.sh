#!/bin/bash 
# Execute a fetch including tags
# Remove branch references to branches that don't exist on the remote anymore branches

git fetch --all --prune --tags >/dev/null