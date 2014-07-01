#!/usr/bin/env bash
# ********************************************************************
#
#     Gitのローカルリポジトリからリモートリポジトリを作成する。
#
#                                            (c) 2013 - 2014 tyabuta.
# ********************************************************************

git status > /dev/null 2>&1
if [ 0 -ne $? ]; then
    echo "Current directory is not git repository."
    exit 1
fi

remote=$1
if [ -z "$remote" ]; then
    echo "usage: ${0##*/} <RemoteRepository>"
    exit 1
fi


currentDir=$(pwd)
mkdir -p $remote
cd $remote
git --bare init
cd $currentDir


git remote remove origin
git remote add origin $remote
git push -u origin master

