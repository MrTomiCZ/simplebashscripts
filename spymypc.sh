#!/bin/bash
SMP_SOURCE="https://github.com/MrTomiCZ/simplebashscripts/raw/refs/heads/main/spymypc.sh"
SMP_DEPS=('curl' 'less' 'cat' 'diff' 'cmp')
# deps
for item in "${SMP_DEPS[@]}"; do
    #echo "checking if $item"
    if command -v "$item" >/dev/null 2>&1; then
        :
    else
        toolErr "$item"
    fi
done

URLLOC="$HOME/.spymypc.url"
URL="$(cat "$URLLOC")"
GETWINCMD="kdotool getactivewindow getwindowname"
TOKENLOC="$HOME/.spymypc.token"
TOKEN="$(cat "$TOKENLOC")"
EMPLOYMENTPID=0
#GETWMCMD="./getwm.sh"
sendWebhook() {
    curl -sS "$URL" -d "$2" -H "Title: SpyMyPC: $1" -H "Authorization: Bearer $TOKEN" > /dev/null
}

cleanup() {
    printf "\nstopping gimme a sec im killing curl\n" &
    # Remove trap to prevent recursive loop calls
    trap - EXIT #INT TERM

    # Send webhook in background so it doesn't block exit
    sendWebhook "Stopped" "EXIT signal received: SpyMyPC closed." &

    # Close coproc file descriptors
    exec {spymypc[0]}<&- 2>/dev/null
    exec {spymypc[1]}>&- 2>/dev/null

    # Kill the coproc process
    if [[ -n "$EMPLOYMENTPID" ]]; then
        kill "$EMPLOYMENTPID" 2>/dev/null || true
        wait "$EMPLOYMENTPID"
    fi

    exit 0
}

toolErr() {
    echo "$1 doesn't exist"
    echo "please install or edit source"
    echo "to use a tool of your choice"
    exit 1
}

#version check
if (( BASH_VERSINFO[0] >= 4 )); then
    :
else
    echo "you do not meet the necessary requirements for"
    echo "receiving commands so either implement it yourself lol"
    echo "or download bash 4.0 or higher ty"
    exit 1
fi


#if [ -f "$GETWMCMD" ]; then

#else
#fi
if [[ "$XDG_CURRENT_DESKTOP" == "KDE" && "$XDG_SESSION_TYPE" == "wayland" ]];then
    if command -v kdotool >/dev/null 2>&1; then
        #echo "exists"
        :
    else
        toolErr kdotool
    fi
elif [[ "$XDG_SESSION_TYPE" == "x11" ]];then
    echo "X11 is experimental"
    if command -v xdotool >/dev/null 2>&1; then
        GETWINCMD="xdotool getactivewindow getwindowname"
    else
        toolErr xdotool
    fi
else
# Fallback checks if XDG_SESSION_TYPE is not set
    if [ -n "$WAYLAND_DISPLAY" ]; then
        echo "non KDE Wayland is currently not supported"
        echo "if you have a solution please create an issue at"
        echo "github on MrTomiCZ/simplebashscripts"
        echo "https://github.com/MrTomiCZ/simplebashscripts"
        exit 1
    elif [ -n "$DISPLAY" ]; then
        echo "X11 is experimental"
        if command -v xdotool >/dev/null 2>&1; then
            GETWINCMD="xdotool getactivewindow getwindowname"
        else
            toolErr xdotool
        fi
    else
        echo "Unknown session or DE/WM not supported"
    fi
fi

# Updater
curl -fsSL https://github.com/MrTomiCZ/simplebashscripts/raw/refs/heads/main/spymypc.sh -o /tmp/spymypc.sh
if [[ ! -s /tmp/spymypc.sh ]]; then
    echo "Failed to download update"
    #exit 1
fi
if cmp -s '/tmp/spymypc.sh' "$(readlink -f "$0")"; then
    echo "Up to date"
else
    diff --color=always '/tmp/spymypc.sh' "$(readlink -f "$0")" | less -R

    while true; do
        read -p "Update? [yn] " answer

        case "$answer" in
            [Yy])
                echo "Updating"
                cp --preserve=mode /tmp/spymypc.sh "$0.tmp"
                mv "$0.tmp" "$0"
                rm /tmp/spymypc.sh
                exec "$0"
                break
                ;;
            [Nn])
                echo "alr not updating"
                break
                ;;
            *)
                echo "invalid"
                ;;
        esac
    done
fi


trap cleanup EXIT # INT TERM

sendWebhook "Started" "SpyMyPC is running at $USER@$HOSTNAME on $(uname), PID $$"
coproc spymypc { exec curl -NsS -H "Authorization: Bearer $TOKEN" "$URL/raw"; }
EMPLOYMENTPID=$spymypc_PID
ACTIVEWIN="$($GETWINCMD)"
while [ true ]; do
    CURRENTWIN="$($GETWINCMD)"
    if read -r -t 0.1 output <&"${spymypc[0]}"; then
        if [[ "$output" == "stop" || "$output" == "exit" ]]; then
            exit 123
        elif [[ "$output" == "notify "* ]]; then
            notify-send "${output#"notify "}"
        elif [[ "$output" == "cmd "* ]]; then
            cmd="${output#"cmd "}"
            eval "$cmd"
        fi
    fi
    if [[ "$CURRENTWIN" != "$ACTIVEWIN" && "$CURRENTWIN" != "" ]]; then
        sendWebhook "Active window changed" "$CURRENTWIN"
        ACTIVEWIN="$CURRENTWIN"
    fi
done
