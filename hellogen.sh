#!/usr/bin/env bash
# *******************************************************************
#
#              各種スクリプトのHelloWorldを作成する。
#
#                                           (c) 2013 - 2014 tyabuta.
# *******************************************************************




function _chmod_and_run(){
    chmod 755 $1
    $1
}

function make_shell(){
    path="./hello.sh"
    cat <<__SRC__ > $path
#!/usr/bin/env bash

echo "Hello ShellScript!"

__SRC__

    _chmod_and_run $path
}


function make_python(){
    path="./hello.py"
    cat <<__SRC__ > $path
#!/usr/bin/env python
# -*- coding: utf-8 -*-


if "__main__" == __name__ :
    print("Hello Python!")

__SRC__

    _chmod_and_run $path
}


function make_ruby(){
    path="./hello.rb"
    cat <<__SRC__ > $path
#!/usr/bin/env ruby
# encoding: utf-8

puts "Hello Ruby!"

__SRC__

    _chmod_and_run $path
}

function make_php(){
    path="./hello.php"
    cat <<__SRC__ > $path
#!/usr/bin/env php
<?php

print 'Hello PHP!' . "\n";

__SRC__

    _chmod_and_run $path
}


function make_perl(){
    path="./hello.pl"
    cat <<__SRC__ > $path
#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

print "Hello Perl!\n";

__SRC__

    _chmod_and_run $path
}

function make_html(){
    path="./hello.html"
    cat <<__SRC__ > $path
<!DOCTYPE>
<html lang="ja">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>HelloWorld</title>
<link href="http://szk-engineering.com/markdown.css" rel="stylesheet"></link>
<script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>
</head>
<body>
<h1>- Hello World! -</h1>

</body>
</html>
__SRC__
}


LANGS="shell python ruby html php perl"

# -----------------------------------------------
# main
# -----------------------------------------------
PS3=">>> "
select key in $LANGS Cancel; do
    case $key in
    shell)  make_shell;  break;;
    python) make_python; break;;
    ruby)   make_ruby;   break;;
    html)   make_html;   break;;
    php)    make_php;    break;;
    perl)   make_perl;   break;;
    *) break;;
    esac
done


