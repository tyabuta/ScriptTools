#!/usr/bin/env ruby
######################################################################
#
#          カレントブランチをgit pushする為のスクリプト
#
#                                                   (c) 2013 tyabuta.
######################################################################

# __Func__

#
# カレントブランチを取得する。
# 取得に失敗した場合は空文字列を返す。
#
def GitBrantchGetCurrent()
    git_status = `git status 2>&1`
    if git_status =~ /# On branch (.+)$/ then
        current_branch = $1
        return current_branch
    end
    return ""
end


# __Main__

# カレントブランチの取得
current_branch = GitBrantchGetCurrent()
if "" == current_branch then
    puts "カレントブランチの取得に失敗しました。"
    exit 1
end

system "git push origin #{current_branch}"


