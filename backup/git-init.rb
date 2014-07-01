#!/usr/bin/env ruby
# encoding: utf-8

# ********************************************************************
#
#                 Gitリポジトリの初期化スクリプト
#
#                                                   (c) 2013 tyabuta.
# ********************************************************************

# -------------------------------------------------------------------
# 指定ファイルに文字列を追記する。
# -------------------------------------------------------------------
def FileWriteAppend(filename, str)
    open(filename, "a") do |f|
        f.write str
        return true
    end
    return false
end

# -------------------------------------------------------------------
# Data構造処理用の関数
# -------------------------------------------------------------------
def AppendData(data)
    ret = FileWriteAppend(data[:filename], data[:text])
    if ret then
        puts data[:message]
    end
end



# __Main__

DATA = [
{ :filename => ".gitignore",
   :message => "[write] .gitignore",
      :text => <<"EOF"
.DS_Store
project.xcworkspace/
xcuserdata/

# for Symfony
app/cache/*
app/logs/*
EOF
},

{ :filename => ".gitattributes",
   :message => "[write] .gitattributes",
      :text => <<'EOF'
*.ai binary
*.xib bi
\!*.pbxproj binary
EOF
},
] # End of DATA


# git init --------------------------------------
ret = system("git init")
if ret then
    puts "[init] git repository"
else
    abort
end

# file apppend ----------------------------------
DATA.each do |data|
    AppendData data
end

exit 0

