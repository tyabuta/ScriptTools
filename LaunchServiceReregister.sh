#!/usr/bin/env bash
#####################################################################
#
# Mac用
# "このアプリケーションで開く"のアプリ名が重複するようになった場合に
# LaunchServiceの登録をやり直すスクリプト。
#
#                                           (c) 2012 - 2013 tyabuta.
#####################################################################

# Macじゃないなら実行しない。
if [ "Darwin" != `uname` ] ; then
    echo "Not Darwin"
    exit 1
fi

# LaunchServiceの登録し直し。
/System/Library/Frameworks/CoreServices.framework//Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain user

# Finder再起動
killall Finder

exit 0


