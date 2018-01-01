#!/usr/bin/env bash

set -u

tokenDir=~/.config/net/tyfunction/git-clone-gitlab
tokenFile=token.enc

if [ ! -f "$tokenDir/$tokenFile" ]; then
    echo "Enter PrivateToken"
    read inputToken

    mkdir -p $tokenDir
    echo "$inputToken" | openssl aes-256-cbc -e -base64 -out $tokenDir/$tokenFile
    echo "Private-Token saved."
fi

# token取得
token=$(cat $tokenDir/$tokenFile | openssl aes-256-cbc -d -base64)
if [ 0 -ne $? ]; then
    echo "Invalid password."
    exit 1
fi

# リポジトリ一覧取得
repos=$(curl --header "Private-Token: $token" https://gitlab.com/api/v3/projects | \
    jq -r ".[].ssh_url_to_repo"  | \
    sort)
if [ -z "$repos" ]; then
    echo "取得出来るリポジトリがみつかりません"
    exit 1
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

