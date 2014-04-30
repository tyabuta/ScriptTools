#!/usr/bin/env bash

# 指定ファイルPATH
file=$1
if [ -z "$file" ]; then
    echo "usage: ${0##*/} <File|Directory>"
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

# upload
if [ -f "$file" ]; then
    scp -i $rsaKey $file $host:$remoteDir

elif [ -d "$file" ]; then
    scp -i $rsaKey -r $file $host:$remoteDir

else
    echo "無効なファイルです"
    exit 1
fi

