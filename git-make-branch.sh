#!/usr/bin/env bash

newBranch=$1
if [ -z "$newBranch" ]; then
    echo "usage: ${0##*/} <NewBranch>"
    exit 1
fi


# make branch
git checkout -b $newBranch

echo -n "push remote? [yes/No] "
read answer
case $answer in
    "Y" | "y" | "yes" | "Yes" | "YES" ) ;;
    * ) exit 0 ;;
esac


# push remote
git push -u origin $newBranch


