#!/usr/bin/env bash

PS3=">>> "
select key in Normal OneLine FileNames Cancel; do
    case $key in
    Normal)
        git log
        break;;
    OneLine)
        git log --pretty=format:"%h - %ad %an '%s'" --date=iso
        break;;
    FileNames)
        git log --name-status
        break;;
    *)
        break;;
    esac
done

