#!/usr/bin/env bash

PROJECT_DIR="proj"

mkdir -p $PROJECT_DIR
mkdir -p $PROJECT_DIR/views


cat <<__TEXT__ > $PROJECT_DIR/Gemfile
source 'https://rubygems.org'
gem 'sinatra'
gem 'sinatra-reloader'
__TEXT__


cat <<__TEXT__ > $PROJECT_DIR/app.rb
#!/usr/bin/env ruby
# encoding: utf-8

require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader'

get '/' do
    @title = 'Hello World!'
    erb :index
end

__TEXT__
chmod a+x $PROJECT_DIR/app.rb


cat <<__TEXT__ > $PROJECT_DIR/views/index.erb
<!DOCTYPE>
<html lang="ja">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title><%= @title %></title>
</head>
<body>
<h1>- <%= @title %> -</h1>
</body>
</html>
__TEXT__


cd $PROJECT_DIR
bundle install --path vender/bundle

cat <<__MSG__
Generate complete!
__MSG__


