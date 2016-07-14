#!/usr/bin/env bash
# -----------------------------------------------
#      git log --graph
# -----------------------------------------------

ALL_OPTION=""
while getopts a OPT
do
  case $OPT in
    "a" ) ALL_OPTION="--all" ;;
      * ) usage ;;
  esac
done
shift $(( $OPTIND - 1 ))

FORMAT="%C(yellow)%h%C(reset) %C(magenta)[%ad]%C(reset)%C(auto)%d%C(reset) %s %C(cyan)@%an%C(reset)"
git log --graph $ALL_OPTION --date=short --format="$FORMAT"

