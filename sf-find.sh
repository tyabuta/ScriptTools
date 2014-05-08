#!/usr/bin/env bash


# -----------------------------------------------
# functions
# -----------------------------------------------


function usage(){
    echo "usage: ${0##*/} [-s | --schema] [-r | --routing] [-a | --action] [-t | --template] <Keyword>"
}



# symfonyのルーティング検索をおこなう
# sf-routing-search <Keyword>
function sf-routing-search(){
    local keyword=$1
    find ./ -iname "routing.yml" | xargs grep -5 "$keyword"
}

# symfonyのスキーマ検索をおこなう
# sf-schema-search <Keyword>
function sf-schema-search(){
    local keyword=$1
    find ./ -iname "*schema.yml" | xargs grep -n "$keyword"
}

# symfonyのテンプレートファイルの検索をおこなう
# sf-template-search <Action>
function sf-template-search(){
    local actionName=$1
    find ./ -iname "${actionName}Success.php"
}

# symfonyのアクションメソッドの検索をおこなう
# sf-action-search <Action>
function sf-action-search(){
    local actionName=$1
    find ./ -iname "actions.class.php" | xargs grep -n "execute${actionName}"
}

# -----------------------------------------------
# main
# -----------------------------------------------

# オプション解析
while :; do
    case "$1" in
    -h | --help | -\?) usage; exit 0;;
    -a | --action)   actionGrepFlag=true;   shift;;
    -t | --template) templateFindFlag=true; shift;;
    -r | --routing)  routingGrepFlag=true;  shift;;
    -s | --schema)   schemaGrepFlag=true;   shift;;
    -*) printf >&2 "WARN: Unknown option (ignored) %s\n" "$1"; shift;;
    *) break;;
    esac
done

if [ -z "$1" ]; then
    usage; exit 1
fi

[ true = "$schemaGrepFlag" ]   && sf-schema-search   $1
[ true = "$routingGrepFlag" ]  && sf-routing-search  $1
[ true = "$actionGrepFlag" ]   && sf-action-search   $1
[ true = "$templateFindFlag" ] && sf-template-search $1



