#!/usr/bin/env bash

ssh_config="$HOME/.ssh/config"

if [ ! -f "$ssh_config" ]; then
    echo "no such file ($ssh_config)"
    exit 0
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
    Cancel) exit 0;;
    *) break;;
    esac
done

# do ssh connection
ssh $host

