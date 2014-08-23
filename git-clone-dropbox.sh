#!/usr/bin/env bash

REPO_DIR="~/Dropbox/Repositories"

# リポジトリ一覧取得
repos=$(eval find $REPO_DIR -name HEAD | sed -e "s/^\(.*\)\/HEAD$/\1/")
if [ -z "$repos" ]; then
    echo "取得出来るリポジトリがみつかりません"
    exit 0
fi

# 取得するリポジトリを選択
echo "取得するリポジトリを選んでください"
PS3='>>> '
select repository in $repos; do
    [ -z "$repository" ] && exit 0
    break
done

# git clone
git clone --recursive $repository

