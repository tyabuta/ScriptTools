#!/usr/bin/env ruby
# encoding: utf-8
# *******************************************************************
#
#                実行可能なスクリプトを列挙する。
#
#                                                  (c) 2013 tyabuta.
# *******************************************************************


# __Const__

CommandDirectories = [
    '~/Dropbox/bin',
    '~/ScriptTools',
    '~/bin',
]


# __Func__

# -------------------------------------------------------------------
# 指定ディレクトリ内のコマンド配列を取得する。
# -------------------------------------------------------------------
def getCommandList(dir)
    arr = []

    # 実行権限が付与された、コマンド名を列挙する。
    res = `find #{dir} -maxdepth 1 -type f -perm -111 -exec basename {} \\;`
    res.each_line do |a|
        a.chomp!
        arr.push(a)
    end
    return arr
end


# __Main__

CommandDirectories.each do |a|
    if File.exist?(File.expand_path(a)) then
        puts "[ #{a} ]"
        getCommandList(a).each do |file|
            puts '    ' + file
        end

    end
end

puts ''


