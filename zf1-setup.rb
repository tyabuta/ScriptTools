#!/usr/bin/env ruby
# encoding: utf-8
# *******************************************************************
#
#          ZendFramework1 のプロジェクトを作成する。
#
#                                                  (c) 2013 tyabuta.
# *******************************************************************


print "アプリケーション名を入力してください。\n>>> "
app = gets.chomp
if "" == app then
    exit 1
end

# ZF1のダウンロード
system 'git clone https://github.com/zendframework/zf1.git'

# プロジェクト作成
system "./zf1/bin/zf.sh create project #{app}"
system "cp -r zf1/library/* #{app}/library/"
system "mkdir #{app}/logs"
system "chmod 777 #{app}/logs"


# Virtualhostの設定例ファイルを出力
pwd = `pwd`.chomp

vhost = <<EOF
Listen 10080
<VirtualHost *:10080>
    ServerAdmin admin@mail.com
    DocumentRoot "#{pwd}/#{app}/public"
    ErrorLog     "#{pwd}/#{app}/logs/error.log"
    CustomLog    "#{pwd}/#{app}/logs/access.log" common

    # リリース時にはコメントアウトしておく事。
    SetEnv APPLICATION_ENV development

    <Directory "#{pwd}/#{app}/public">
        Options Indexes FollowSymLinks MultiViews ExecCGI
        AllowOverride All
        Order deny,allow
        Allow from all
        AddHandler cgi-script .cgi
    </Directory>
</VirtualHost>
EOF

open('vhost.txt', "w") do |f|
    f.write vhost
end

