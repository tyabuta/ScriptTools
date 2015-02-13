#!/usr/bin/env bash


branch=$1
if [ -z "$branch" ]; then
    echo "usage: ${0##*/} <NewBranchName>"
    exit 1
fi

git checkout -b "$branch" && git push -u origin "$branch"

