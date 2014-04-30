#!/usr/bin/env bash


# -----------------------------------------------
# functions
# -----------------------------------------------

function upload(){
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
    if [ "/" = `echo $file | cut -c ${#file}-${#file}` ]; then
        scp -i $rsaKey -r $host:$file ./
    else
        scp -i $rsaKey $host:$file ./
    fi
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


if [ "true" = "$uploadFlag" -a "true" = "$downloadFlag" ]; then
    echo "usage: <-u|-d> ${0##*/} <File|Directory>"
    exit 1

elif [ "true" != "$uploadFlag" -a "true" != "$downloadFlag" ]; then
    echo "usage: <-u|-d> ${0##*/} <File|Directory>"
    exit 1
fi

# 指定ファイルPATH
file=$1
if [ -z "$file" ]; then
    echo "usage: <-u|-d> ${0##*/} <File|Directory>"
    exit 1
fi


# 設定ファイルの存在確認
yamlPath="$HOME/.scp-loader.yml"
if [ ! -e "$yamlPath" ]; then
    echo "$yamlPath is not exists."
    exit 1
fi

# 設定読み込み
rsaKey=`ruby -r yaml -e "puts YAML.load(open('$yamlPath').read)['rsa-key']"`
host=`ruby -r yaml -e "puts YAML.load(open('$yamlPath').read)['host']"`
remoteDir=`ruby -r yaml -e "puts YAML.load(open('$yamlPath').read)['remote-dir']"`

if [ "true" = "$uploadFlag" ]; then
    upload
elif [ "true" = "$downloadFlag" ]; then
    download
fi

