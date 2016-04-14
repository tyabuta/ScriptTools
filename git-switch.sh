#!/usr/bin/env bash
# -----------------------------------------------
#      branchの切り替えを選択できる
# -----------------------------------------------

function usage(){
    echo "usage: ${0##*/} [-r]"
    echo "    -r  Remote branches"
    exit 1
}

function color_green(){
    if which tput > /dev/null 2>&1; then
        echo "$(tput setaf 2)$1$(tput sgr 0)"
        return
    fi
    echo "$1"
}

function get_remote_branches()
{
    git branch -r | perl -ne '
if ($_ =~ /origin\/(.*) ->.*/i){
     print $1 . "\n";
}
elsif ($_ =~ /origin\/(.*)/i){
     print $1 . "\n";
}
'
}

function get_local_branches()
{
    git branch | perl -pe 's/[\* ]//g'
}


REMOTE_BRANCH="no"
while getopts r OPT
do
  case $OPT in
    "r" ) REMOTE_BRANCH="yes" ;;
      * ) usage ;;
  esac
done
shift $(( $OPTIND - 1 ))


# 現在のブランチ取得
curretBranch=$(git branch | awk '/^\* .+/ { print $2 }')
[ -z "$curretBranch" ] && exit 1

# ブランチリストを取得
if [ "yes" == "$REMOTE_BRANCH" ]; then
    branches=$(get_remote_branches)
else
    branches=$(get_local_branches)
fi

if which fzf > /dev/null 2>&1; then
    msg="SELECT (on branch $curretBranch) >>> "
    branch=$(echo "$branches" | fzf --prompt="$msg")
    [ -z "$branch" ] && exit 0
else
    echo "SELECT (on branch $(color_green "$curretBranch"))"
    PS3='>>> '
    select branch in $branches; do
        [ -z "$branch" ] && exit 0
        break
    done
fi

# checkout
git checkout $branch

