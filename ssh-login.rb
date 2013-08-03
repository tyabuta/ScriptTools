#!/usr/bin/env ruby
# encoding: utf-8
#####################################################################
#
#                 ホストサーバー接続用のスクリプト
#                 複数の接続先を選択する事ができる。
#
#                                                  (c) 2013 tyabuta.
#####################################################################

require 'optparse'
require 'yaml'


# --- Const ---

# バージョン
Version = '1.1.0'

# 設定ファイル読み込みのPATH
CONF_PATH = '~/.sshlogin.yml'

# 設定ファイルのテンプレート
CONF_TEMPLATE = <<"EOF"
-  server: ServerName1
  command: ssh User@host1
-  server: ServerName2
  command: ssh User@host2 -p 22 -i ~/.ssh/id_rsa
EOF




# --- Func ---

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


# -------------------------------------------------------------------
# ハッシュ配列から、指定キーの値で配列を作成する。
# -------------------------------------------------------------------
def ArrayMakeWithHashKey(hash_array, key)
    arr = []
    hash_array.each { |hash| arr.push(hash[key]) }
    return arr
end

# -------------------------------------------------------------------
# ヘルプメッセージ出力用の関数
# -------------------------------------------------------------------
def PrintHelp()
    puts <<"EOF"
ホストサーバー接続用のスクリプト
コマンドを起動すると接続するホスト先を選択できます。
※設定ファイルを作成しておく必要があります。

設定ファイルを作成するには下記コマンドを使用する事で雛形を作成できます。
#{File.basename($0)} -o > #{CONF_PATH}

#{CONF_PATH} の設定例
#{'-' * 50}
#{CONF_TEMPLATE.chomp}
#{'-' * 50}
EOF
end


# -------------------------------------------------------------------
# オプション解析の関数
# -------------------------------------------------------------------
def OptionParse()
    opt = OptionParser.new
    opt.on('-h', '--help') {
        PrintHelp()
        exit 0
    }
    opt.on('-o', '--output-conf') {
        puts CONF_TEMPLATE
        exit 0
    }
    opt.parse!(ARGV)
end




# --- Main ---

# オプション解析
OptionParse()


# YAMLファイルの存在確認
yaml_file_path = File.expand_path(CONF_PATH)
if false == File.exist?(yaml_file_path) then
    puts  yaml_file_path + ' ファイルが見つかりません。'
    exit -1
end

# YAMLの読み込み
ssh_conf = YAML.load_file(yaml_file_path)

# serverの配列を作成
selectable_items = ArrayMakeWithHashKey(ssh_conf, 'server')

# ユーザーに選択させる。
msg              = 'SSH接続するサーバーを選択してください。'
selected_index   = PromptSelectMenuWithArray(selectable_items, msg)
if -1 != selected_index then
    # 接続コマンド実行
    ret = system ssh_conf[selected_index]['command']
    exit ret
end

exit 1

