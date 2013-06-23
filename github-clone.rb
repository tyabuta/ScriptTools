#!/usr/bin/env ruby
# *******************************************************************
#
#               GitHubのユーザーリポジトリの一覧から
#               クローンするリポジトリを選択できる。
#
#                                                 (c) 2013 tyabuta.
# *******************************************************************


require 'json'
require 'net/https'
Net::HTTP.version_1_2


# -------------------------------------------------------------------
# プロンプトによる項目の選択関数
#           arr: 選択項目となる文字列配列
#           msg: 選択を促す、メッセージ文字列
# returnByIndex: インデックスで選択項目を返すか。
#                true (default) -> 選択された項目のインデックスを返します。
#                                  Cancelが選択された場合 -1
#                false          -> 選択された項目の文字列を返します。
#                                  Cancelが選択された場合 nil
# -------------------------------------------------------------------
def PromptSelectMenuWithArray(arr, msg, returnByIndex = true)
    puts msg
    puts "0) cancel"
    arr.each_with_index { |a, i| puts "#{i+1}) #{a}" }

    # 入力を求める。
    print ">> "; idx = gets.to_i() -1

    # インデックス指定の場合、数値を返す。
    return idx if returnByIndex

    # インデックス指定でない場合、無効値はnilを返す。
    return nil if -1 == idx
    return arr[idx]
end

# -------------------------------------------------------------------
# GitHubから、ユーザーのリポジトリ一覧をJSON形式で取得する。
# ※GitHub APIを利用。
# レスポンスヘッダが200を返さなかった場合には、
# 取得失敗としてnilを返します。
#
# username: GitHubのユーザー名
# -------------------------------------------------------------------
def GitHubUserRepositories(username)
    # GitHub API
    url = "https://api.github.com/users/" + username + "/repos"

    # URIに変換
    uri = URI(url)

    # HTTPSによるレスポンス取得
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl     = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE # 証明書を必要としない
    https.start {
        response = https.get(uri.path)
        case response
        when Net::HTTPOK then
            # JSONオプジェクトを返す。
            return JSON.parse(response.body)
        else
            # Error
        end
    }
    return nil
end


# -------------------------------------------------------------------
# リポジトリへのアクセス方法別のURL配列を返す。
# -------------------------------------------------------------------
def urlsTypeOfAccessMethod(repository)
    return [
        repository["ssh_url"],
        repository["git_read_only"],
        repository["http"],
    ]
end


#
# __Main__
#


# リポジトリ情報の取得
puts "リポジトリデータの取得中... "
json = GitHubUserRepositories("tyabuta")
if nil == json then
    puts "取得に失敗しました！"
    exit(-1)
end
puts "取得完了。"


# JSON解析
repositories     = [] # リポジトリデータの配列
repository_names = [] # リポジトリ名の配列
json.each do |repo,|
    repositories.push({
        "name"          => repo["full_name"],
        "git_read_only" => repo["git_url"],
        "ssh_url"       => repo["ssh_url"],
        "http"          => repo["clone_url"],
    })
    repository_names.push(repo["full_name"])
end


# リポジトリの選択
msg            = "クローンするリポジトリを選択してください。"
selected_index = PromptSelectMenuWithArray(repository_names,msg)
exit 1 if -1 == selected_index


# リポジトリ種類の選択
msg          = "クローンするリポジトリのアクセス方法を選択してください。"
urls         = urlsTypeOfAccessMethod(repositories[selected_index])
selected_url = PromptSelectMenuWithArray(urls, msg, false)
exit 1 if nil == selected_url

# git clone
system "git clone --recursive " + selected_url



