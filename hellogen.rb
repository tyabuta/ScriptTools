#!/usr/bin/env ruby
#####################################################################
# 1.1.0.5
#
#              各種スクリプトのHelloWorldを作成する。
#
#                                                  (c) 2013 tyabuta.
#####################################################################



#
# 正規表現にマッチした行をきっかけに、次の行からファイル読み込みを開始する。
#
# file_object: ファイルオブジェクト
# regex_begin: 読み込みのきっかけとなる正規表現
#   regex_end: 読み込み終了の合図となる正規表現、
#              省略した場合はファイルの最後まで読み込みを行う。
#
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
# Main
# -------------------------------------------------------------------

SCRIPT_TYPES = {
    "ruby"  => ".rb",
    "perl"  => ".pl",
    "shell" => ".sh",
}


script_type     = ARGV[0] or abort "スクリプトタイプが指定されていません。"

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

puts "Hello Ruby!"


@@perl
#!/usr/bin/env perl
use strict;
use warnings;
use utf8;

print "Hello Perl!\n";


@@shell
#!/usr/bin/env bash

echo "Hello ShellScript!"


