#!/bin/sh
# Remove all local tags that don't exist on remote (origin)

git fetch --prune origin +refs/tags/*:refs/tags/*
