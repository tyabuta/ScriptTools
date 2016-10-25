

# === functions ===

processList(){
    pgrep -ilf ssh | grep -e " [0-9]\+:.*:[0-9]\+"
}



# === sub command ===

status(){
    echo "usage:"
    echo "cmd <status | start | stop>"
    echo ""

    echo "status:"
    processList
    echo ""
}

start(){
    local tunnelCommands=$(cat ~/.tunnel)
    local command=$(echo "$tunnelCommands" | fzf)
    if [ -z "$command" ]; then
        echo "キャンセルしました。"
        return 0
    fi

    local port=$(echo "$command" | perl -pe 's/^.* (\d+):.*$/$1/g')
    if lsof -i:$port; then
        echo "[!] Already used port:$port."
        return 0
    fi

    $command
}

stop(){
    local process=$(processList | fzf)
    local pid=$(echo $process | perl -anle 'print "$F[0]"')
    if [ -z "$pid" ]; then
        echo "Not found process."
        return 0
    fi
    kill -9 $pid
}


# === main ===

subCommand=$1
case "$subCommand" in
"stop")       stop   ;;
"start")      start  ;;
"status" | *) status ;;
esac

