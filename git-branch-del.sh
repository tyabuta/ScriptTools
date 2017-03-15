#!/usr/bin/env bash

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
     print ":" . $1 . "\n";
}
elsif ($_ =~ /origin\/(.*)/i){
     print ":" . $1 . "\n";
}
'
}

function get_local_branches()
{
    git branch | perl -pe 's/[\* ]//g'
}


function confirm(){
    echo $@
    echo -n ">>> Are you sure? [yes/No] "
    read ret
    case $ret in
    "yes" | "Yes" | "YES")
        ;;
    *)
        echo "Canceled. "
        exit 0
        ;;
    esac
}




if which fzf > /dev/null 2>&1; then
    :
else
    echo "Not found fzf"
    exit -1
fi


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
currentBranch=$(git branch | awk '/^\* .+/ { print $2 }')
[ -z "$currentBranch" ] && exit 1

# ブランチリストを取得
if [ "yes" == "$REMOTE_BRANCH" ]; then
    branches=$(get_remote_branches)
else
    branches=$(get_local_branches)
fi

msg="SELECT (on branch $currentBranch) >>> "
branch=$(echo "$branches" | fzf --prompt="$msg" --multi --bind=space:toggle)
[ -z "$branch" ] && exit 0

# delete
if [ "yes" == "$REMOTE_BRANCH" ]; then
    confirm git push origin $branch
    git push origin $branch
else
    confirm git branch -D $branch
    git branch -D $branch
fi

