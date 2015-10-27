#!/usr/bin/env bash

branchSrc="$1"
branchDest="$2"

if [ -z "$branchSrc" -o -z "$branchDest" ]; then
    echo "usage: ${0##*/} <BranchDest> <BranchDest>"
    exit 1
fi
git diff $branchDest $branchSrc | patch -p1

