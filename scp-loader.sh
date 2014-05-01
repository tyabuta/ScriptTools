#!/usr/bin/env bash

# 設定変数
yamlPath="$HOME/.scp-loader.yml"
rsaKey=''
host=''
remoteDir=''


# -----------------------------------------------
# functions
# -----------------------------------------------

function upload(){
    loadConfig

    if [ -f "$file" ]; then
        scp -i $rsaKey $file $host:$remoteDir
    elif [ -d "$file" ]; then
        scp -i $rsaKey -r $file $host:$remoteDir
    else
        echo "無効なファイルです"
        return 1
    fi
}

function download(){
    loadConfig

    if [ "/" = `echo $file | cut -c ${#file}-${#file}` ]; then
        scp -i $rsaKey -r $host:$file ./
    else
        scp -i $rsaKey $host:$file ./
    fi
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
while getopts "ud" flag; do
    case $flag in
        u) uploadFlag=true;;
        d) downloadFlag=true;;
    esac
done
shift $(($OPTIND - 1))


# オプション指定が不正な場合
if [ "true" = "$uploadFlag" -a "true" = "$downloadFlag" ] || [ "true" != "$uploadFlag" -a "true" != "$downloadFlag" ]; then
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

if [ "true" = "$uploadFlag" ]; then
    upload
elif [ "true" = "$downloadFlag" ]; then
    download
fi

