#!/usr/bin/env bash
# -----------------------------------------------
#
#      branchの切り替えをlocalから選択する
#
# -----------------------------------------------

# 現在のブランチ取得
curretBranch=$(git branch | awk '/^\* .+/ { print $2 }')
[ -z "$curretBranch" ] && exit 1

# ローカルブランチを取得
branches=$(git branch | awk '{buf=sprintf("%s %s ", buf, $0)} END{print buf}' | sed -e 's/\*//g')

echo "切り替えるブランチを選んでください (on branch $(tput setaf 2)${curretBranch}$(tput sgr 0))"
PS3='>>> '
select branch in $branches; do
    [ -z "$branch" ] && exit 0
    break
done

# checkout
git checkout $branch

