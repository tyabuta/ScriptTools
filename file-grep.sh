#!/usr/bin/env bash

if [ -z "$1" -o -z "$2" ]; then
    echo "usage: ${0##*/} <Filename> <Keyword>"
    exit 1
fi

inameOptions=$(echo "$1" | awk '{
    num = split($0, arr, ",");
    for (i=1; i<=num; i++) {
        if (1!=i) printf("-o ");
        printf("-iname \"%s\" ", arr[i]);
    }
}')

eval find ./ $inameOptions | xargs grep -n "$2"

