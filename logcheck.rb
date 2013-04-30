#!/usr/bin/env ruby
#####################################################################
# 1.2.0.6
#                   各種ログの出力を行う。
#                                                  (c) 2013 tyabuta.
#####################################################################

#
# ログと、出力処理の定義
#
Behaviors= {
    "system.log"=> lambda{
        system "cat /var/log/system.log"
    },
    
    "auth.log"=> lambda{
        system "cat /var/log/auth.log"
    },

    "apache2-access.log"=> lambda{
        system "cat /var/log/apache2/access_log"
    },

    "apache2-error.log"=> lambda{
        system "cat /var/log/apache2/error_log"
    },
    
} # ~Behaviors

#
# 選択肢出力用の関数
#
def outputChoices()
    puts "出力するログの種類を選択してください。";
    puts "0) cancel"
    Behaviors.keys.sort.each_with_index { |tag, i| puts "#{i+1}) #{tag}" }
end


# __Main__

while 1
    # 選択肢出力
    outputChoices()

    # ナンバー入力を要求、ゼロならループを抜ける。
    print ">> "; i = gets.to_i; break if 0==i
    
    if 0 < i && i <= Behaviors.count then
        # Behaviorを実行し、ループから抜ける。
        key = Behaviors.keys.sort[i-1]
        Behaviors[key].call()
        break;
    end
end 

exit 0

