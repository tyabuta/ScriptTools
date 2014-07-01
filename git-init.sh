#!/usr/bin/env bash
# ********************************************************************
#
#                 Gitリポジトリの初期化スクリプト
#
#                                            (c) 2013 - 2014 tyabuta.
# ********************************************************************

if git status > /dev/null 2>&1; then
    echo "Already initialized."
    exit 1
fi

# do git initialize
git init

# add .gitignore
echo "[write] .gitignore"
cat <<__TEXT__ >> .gitignore
.DS_Store
project.xcworkspace/
xcuserdata/

# for Symfony
app/cache/*
app/logs/*
__TEXT__


# add .gitattributes
echo "[write] .gitattributes"
cat <<__TEXT__ >> .gitattributes
*.ai binary
*.xib bi
\!*.pbxproj binary
__TEXT__




