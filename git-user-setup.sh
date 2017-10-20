#!/usr/bin/env bash

NAME=tyabuta
EMAIL=gmforip@gmail.com

name=$(git config user.name)
if [ "$NAME" != "$name" ]; then
    git config user.name $NAME
fi

email=$(git config user.email)
if [ "$EMAIL" != "$email" ]; then
    git config user.email $EMAIL
fi


git config -l

