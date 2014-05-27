#!/usr/bin/env bash
# -----------------------------------------------
#
# SQL Exportしたデータから、
# 指定カラムのデータのみ出力する。
#
#                              (c) 2015 tyabuta.
# -----------------------------------------------


function usage(){
    echo "usage: ${0##*/} [-f N] <SQL-File>"
}


field=0

# オプション解析
while :; do
    case "$1" in
    -h | --help | -\?) usage; exit 0;;
    -f) field=$2; shift 2;;
    -*) printf >&2 "WARN: Unknown option (ignored) %s\n" "$1"; shift;;
    *) break;;
    esac
done


sqlFile=$1
if [ ! -f "$sqlFile" ]; then
    usage; exit 0
fi


cat "$sqlFile" | awk -v field="$field" '
/^\(.+\)[,;]$/{
    gsub(/[\(\);]/,"");
    split($0, arr, ",");
    str = arr[field]
    sub(/^\s+/, "", str);
    sub(/\s+$/, "", str);
    print str;
}
'


