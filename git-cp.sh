#!/usr/bin/env bash

# 別のブランチからファイルをコピーする

function usage(){
    echo "usage: ${0##*/} <Branch> <File>"
    exit 1
}

branch="$1"
file="$2"
if [ -z "$branch" -o -z "$file" ]; then
    usage
fi

git show $branch:$file > $file

