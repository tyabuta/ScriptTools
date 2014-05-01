#!/usr/bin/env bash

# 設定変数
dryRunFlag=false
yamlPath="$HOME/.scp-loader.yml"
rsaKey=''
host=''
remoteDir=''


# -----------------------------------------------
# functions
# -----------------------------------------------

function upload(){
    loadConfig
    [ true = "$dryRunFlag" ] && return 0

    local recursivelyCopyOption=''
    if   [   -d "$file" ]; then recursivelyCopyOption='-r'
    elif [ ! -f "$file" ]; then echo "$file is not exists."; return 1
    fi

    scp -i $rsaKey $recursivelyCopyOption $file $host:$remoteDir
}

function download(){
    loadConfig
    [ true = "$dryRunFlag" ] && return 0

    local recursivelyCopyOption=''
    if [ "/" = `echo $file | cut -c ${#file}-${#file}` ]; then
        recursivelyCopyOption='-r'
    fi

    scp -i $rsaKey $recursivelyCopyOption $host:$file ./
}

function loadConfig(){
    rsaKey=`ruby -r yaml -e "puts YAML.load(open('$yamlPath').read)['rsa-key']"`
    host=`ruby -r yaml -e "puts YAML.load(open('$yamlPath').read)['host']"`
    remoteDir=`ruby -r yaml -e "puts YAML.load(open('$yamlPath').read)['remote-dir']"`
}

function usage(){
    echo "usage: <-u | -d> ${0##*/} <File | Directory>"
}

# -----------------------------------------------
# main
# -----------------------------------------------

# オプション解析
while getopts 'udn' flag; do
    case $flag in
        n) dryRunFlag=true;;
        u) uploadFlag=true;;
        d) downloadFlag=true;;
    esac
done
shift $(($OPTIND - 1))


# オプション指定が不正な場合
if [ true = "$uploadFlag" -a true = "$downloadFlag" ] || [ true != "$uploadFlag" -a true != "$downloadFlag" ]; then
    usage; exit 1
fi

# ファイル指定が無い場合
file=$1
if [ -z "$file" ]; then
    usage; exit 1
fi

# yamlファイルの存在確認
if [ ! -e "$yamlPath" ]; then
    echo "$yamlPath is not exists."
    exit 1
fi

if   [ true = "$uploadFlag" ];   then upload
elif [ true = "$downloadFlag" ]; then download
fi

