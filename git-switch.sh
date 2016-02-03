#!/usr/bin/env bash
# -----------------------------------------------
#
#      branchの切り替えをlocalから選択する
#
# -----------------------------------------------


function color_green(){
    if which tput > /dev/null 2>&1; then
        echo "$(tput setaf 2)$1$(tput sgr 0)"
        return
    fi
    echo "$1"
}


# 現在のブランチ取得
curretBranch=$(git branch | awk '/^\* .+/ { print $2 }')
[ -z "$curretBranch" ] && exit 1

# ローカルブランチを取得
branches=$(git branch | awk '{buf=sprintf("%s %s ", buf, $0)} END{print buf}' | sed -e 's/\*//g')

echo "切り替えるブランチを選んでください (on branch $(color_green "$curretBranch"))"
PS3='>>> '
select branch in $branches; do
    [ -z "$branch" ] && exit 0
    break
done

# checkout
git checkout $branch

