#!/usr/bin/env ruby
# encoding: utf-8

#####################################################################
#
#          カレントディレクトリにWEBrickを起動させる。
#
#                                                  (c) 2013 tyabuta.
#####################################################################
require 'webrick'
include WEBrick

server = HTTPServer.new(
:Port         => 8000,
:DocumentRoot => Dir::pwd
)
trap("INT"){ server.shutdown }
server.start

