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

# download
if [ "/" = `echo $file | cut -c ${#file}-${#file}` ]; then
    scp -i $rsaKey -r $host:$1 ./
else
    scp -i $rsaKey $host:$1 ./
fi

