#!/usr/bin/env ruby
# *******************************************************************
#
#                アーカイブファイルの解凍コマンド
#
#                                                  (c) 2013 tyabuta.
# *******************************************************************

# @Description
#   Output引数を指定しない場合は、
#   圧縮ファイルの拡張子を取り除いたファイル名となる。


# __Main__

# コマンドラインチェック
archive = ARGV[0] || ""
output  = ARGV[1] || ""
if "" == archive then
    puts "usage: #{$0} <ArchiveFile> [Output]"
    exit 1
end

# .gzファイルの場合
if archive =~ /(.*)\.gz$/i then
    if "" == output then
        output = $1
    end
    system "gzip -cd #{archive} > #{output}"

# どれにも該当しないファイルの場合
else
    puts "failed."
    exit 1
end


