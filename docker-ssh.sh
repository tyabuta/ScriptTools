#!/usr/bin/env sh

CONTAINER_ID=$1
if  [ -z "$CONTAINER_ID" ]; then
    echo "usage: cmd <CONTAINER_ID>"
    exit 1
fi

docker exec -it $CONTAINER_ID bash

