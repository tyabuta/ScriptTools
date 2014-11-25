#!/usr/bin/env bash
# -----------------------------------------------
#
#      git push origin <CurrentBranch> の補完
#
# -----------------------------------------------

# 現在のブランチ取得
curretBranch=$(git branch | awk '/^\* .+/ { print $2 }')
[ -z "$curretBranch" ] && exit 1

# git push
git push origin $curretBranch

