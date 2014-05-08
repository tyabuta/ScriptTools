#!/usr/bin/env bash

# 設定変数
dryRunFlag=false

confPath="$HOME/.scp-loader"
[ -f "$confPath" ] && source $confPath


# -----------------------------------------------
# functions
# -----------------------------------------------

function upload(){
    [ true = "$dryRunFlag" ] && return 0

    local recursivelyCopyOption=''
    if   [   -d "$file" ]; then recursivelyCopyOption='-r'
    elif [ ! -f "$file" ]; then echo "$file is not exists."; return 1
    fi

    scp -i $RSA_KEY $recursivelyCopyOption $file $HOST:$REMOTE_DIR
}

function download(){
    [ true = "$dryRunFlag" ] && return 0

    local recursivelyCopyOption=''
    if [ "/" = `echo $file | cut -c ${#file}-${#file}` ]; then
        recursivelyCopyOption='-r'
    fi

    scp -i $RSA_KEY $recursivelyCopyOption $HOST:$file ./
}

function outputConfSkeleton(){
    cat <<CONF
HOST=user@123.0.0.1
REMOTE_DIR=scp-dir/
RSA_KEY=/path/to/rsa-key
CONF
}

function usage(){
    echo "usage: ${0##*/} [-n] [--conf-skeleton | -s] <-u | -d> <File | Directory>"
}

# -----------------------------------------------
# main
# -----------------------------------------------

# オプション解析
while :; do
    case "$1" in
    -h | --help | -\?)    usage;              exit 0;;
    -s | --conf-skeleton) outputConfSkeleton; exit 0;;
    -n) dryRunFlag=true;   shift;;
    -u) uploadFlag=true;   shift;;
    -d) downloadFlag=true; shift;;
    -*) printf >&2 "WARN: Unknown option (ignored) %s\n" "$1"; shift;;
    *) break;;
    esac
done


# オプション指定が不正な場合
if [ true = "$uploadFlag" -a true = "$downloadFlag" ] || [ true != "$uploadFlag" -a true != "$downloadFlag" ]; then
    usage; exit 1
fi

# ファイル指定が無い場合
file=$1
if [ -z "$file" ]; then
    usage; exit 1
fi

if   [ true = "$uploadFlag" ];   then upload
elif [ true = "$downloadFlag" ]; then download
fi

