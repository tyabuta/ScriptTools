#!/usr/bin/env ruby
# encoding: utf-8
# *******************************************************************
#
#              各種スクリプトのHelloWorldを作成する。
#
#                                                  (c) 2013 tyabuta.
# *******************************************************************

# ___Const__

SCRIPT_TYPES = {
    "ruby"    => ".rb",
    "php"     => ".php",
    "perl"    => ".pl",
    "shell"   => ".sh",
    "python3" => ".py",
}



# __Func__

# -------------------------------------------------------------------
# 正規表現にマッチした行をきっかけに、次の行からファイル読み込みを開始する。
#
# file_object: ファイルオブジェクト
# regex_begin: 読み込みのきっかけとなる正規表現
#   regex_end: 読み込み終了の合図となる正規表現、
#              省略した場合はファイルの最後まで読み込みを行う。
# -------------------------------------------------------------------
def ReadBeginWithLine(file_object, regex_begin, regex_end=nil)
    buf = ""
    while file_object.gets
        if $_ =~ regex_begin then
            while file_object.gets
                if regex_end then
                    break if $_ =~ regex_end
                end
                buf += $_
            end
        end
    end
    return buf
end

# -------------------------------------------------------------------
# プロンプトによる項目の選択関数
#           arr: 選択項目となる文字列配列
#           msg: 選択を促す、メッセージ文字列
# returnByIndex: インデックスで選択項目を返すか。
#                true (default)
#                    選択された項目のインデックスを返します。
#                    Cancel、または無効値が選択された場合 -1
#                false
#                    選択された項目の文字列を返します。
#                    Cancel、または無効値が選択された場合 nil
# -------------------------------------------------------------------
def PromptSelectMenuWithArray(arr, msg, returnByIndex = true)
    puts msg
    puts "0) cancel"
    arr.each_with_index { |a, i| puts "#{i+1}) #{a}" }

    # 入力を求める。
    print ">> "; idx = gets.to_i() -1

    # 無効値の場合は全て-1に統一する。
    if idx < 0 || arr.count < idx + 1 then
        idx = -1
    end

    # インデックス指定の場合、数値を返す。
    return idx if returnByIndex

    # インデックス指定でない場合、無効値はnilを返す。
    return nil if -1 == idx
    return arr[idx]
end



# __Main__

# コマンドライン引数のチェック
script_type  = ARGV[0] || ""

# スクリプトタイプが指定されていない場合は、選択させる。
if "" == script_type then
    msg = "スクリプトタイプを選択してください。"
    script_type = PromptSelectMenuWithArray(
                    SCRIPT_TYPES.keys.sort, msg, false) # <- 項目名を返す
    abort if nil == script_type # キャンセル時はabort
end

# スクリプトタイプの整合性チェック
SCRIPT_TYPES.key?(script_type) or abort "指定されたスクリプトには対応していません。"



target_filename = "hello"
target_path     = target_filename + SCRIPT_TYPES[script_type]

# 各種スクリプトのソースコード読み込み
src = ReadBeginWithLine(DATA, /^@@#{script_type}/, /^@@/)

# スクリプトコードの書き込み
open(target_path, "w") { |f| f.write src }
puts "[write] " + File.expand_path(target_path)

# 権限変更(chmod)
system("chmod 755 #{target_path}")
puts "[chmod] 755 #{target_path}"

# HelloWorld実行
print "./#{target_path} >>> "
system("./#{target_path}") or abort "スクリプト実行失敗"

exit 0



__END__

@@ruby
#!/usr/bin/env ruby
# encoding: utf-8

puts "Hello Ruby!"


@@php
#!/usr/bin/env php
<?php

print 'Hello PHP!' . "\n";


@@perl
#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

print "Hello Perl!\n";


@@shell
#!/usr/bin/env bash

echo "Hello ShellScript!"


@@python3
#!/usr/bin/env python3

print("Hello Python3!")

