#!/usr/bin/env bash
# *******************************************************************
#
#                 ホストサーバー接続用のスクリプト
#     ~/.ssh/configに設定された複数の接続先を選択する事ができる。
#
#                                           (c) 2013 - 2014 tyabuta.
# *******************************************************************

ssh_config="$HOME/.ssh/config"

function usage(){
    echo "usage: ${0##*/} [ -o | --output-template ]"
}

function do_ssh_connection(){
    if [ ! -f "$ssh_config" ]; then
        echo "no such file ($ssh_config)"
        return 0
    fi

    # read host list
    hosts=$(cat $ssh_config | awk '
    BEGIN { buf=""; }
    /^\s*[Hh]ost\s+(.*)\s*$/ { buf = buf $2 " ";}
    END   { print buf; }
    ')

    # pick up host
    PS3=">>> "
    select host in $hosts Cancel; do
        case $host in
            Cancel) return 0;;
        *) break;;
    esac
    done
    [ -z "$host" ] && return 0

    # do ssh connection
    ssh $host
}


function do_output_template(){
    cat << __TEXT__
Host dev
HostName 123.0.0.1
Port 22
User root
IdentityFile ~/.ssh/id_rsa
__TEXT__
}


while :; do
    case "$1" in
    -h | --help | -\?)      usage;              exit 0;;
    -o | --output-template) do_output_template; exit 0;;
    -*) printf >&2 "WARN: Unknown option (ignored) %s\n" "$1"; shift;;
    *)  break;;
    esac
done

do_ssh_connection

