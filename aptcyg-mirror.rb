#!/usr/bin/env ruby
# encoding: utf-8
# *******************************************************************
#
#              apt-cyg コマンドのミラー設定を行う。
#
#                                                  (c) 2013 tyabuta.
# *******************************************************************


#
# __Const__
#

# リポジトリのデータ
repos = [
    { 'description' => '標準リポジトリ(日本のMirror)',
      'url'         => 'ftp://ftp.iij.ad.jp/pub/cygwin/'},

    { 'description' => '非公式のリポジトリ',
      'url'         => 'ftp://ftp.cygwinports.org/pub/cygwinports'},
]


#
# __Func__
#

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
# apt-cygコマンドに現在設定されているミラーリポジトリを取得する。
# -------------------------------------------------------------------
def AptCygGetCurrentMirror()
    # default mirror
    mirror = 'ftp://mirror.mcs.anl.gov/pub/cygwin'

    if File.exists?('/etc/setup/last-mirror') then
        mirror = `head -1 /etc/setup/last-mirror`
    end
    return mirror.chomp
end


#
# __Main__
#

# apt-cygコマンドが存在するかチェック
apt_cyg = `which apt-cyg 2> /dev/null`
if "" == apt_cyg then
    puts "apt-cygがインストールされていません。"
    abort -1
end


# 現在設定されているリポジトリを表示
current_mirror = AptCygGetCurrentMirror()
puts "[CurrentMirror] " + current_mirror


# 選択項目用の配列を作成
selectable_items = []
repos.each do |repo,|
    url         = repo['url']
    item_string = ((url == current_mirror) ? '*' : ' ') + url
    selectable_items.push(item_string)
end


# 選択プロンプト
mesasge        = '使用するリポジトリを選択してください。'
selected_index = PromptSelectMenuWithArray(selectable_items, mesasge)
if -1 != selected_index then
    # リポジトリの設定を実行
    ret = system("apt-cyg -m #{ repos[selected_index]['url'] } update")
    exit ret
end


exit 1

