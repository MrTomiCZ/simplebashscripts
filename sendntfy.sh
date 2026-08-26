#!/usr/bin/env bash

# Author: mrtomicz
# WWW: mrtomicz.eu
# Dependencies: cat, cmp, cp, mv, rm, chmod, curl, coproc (bash >= 4.0), jq
# Relies on ntfy: docs.ntfy.sh

SENDNTFY_URL="$1"
SENDNTFY_TOKEN="$(cat $HOME/.sntfy.token)"
SENDNTFY_SRC="https://github.com/MrTomiCZ/simplebashscripts/raw/refs/heads/main/sendntfy.sh"
SENDNTFY_REPO="https://github.com/MrTomiCZ/simplebashscripts"
SENDNTFY_CONTENT="$2"

ntf() {
    printf -v MESSAGE '%b' "$2"
    notify-send --app-name=sendntfy \
        --icon=/usr/share/icons/breeze/status/16/data-information.svg \
        "$1" "$MESSAGE"
    canberra-gtk-play -f /usr/share/sounds/oxygen/stereo/message-highlight.ogg &
}

# Updater
#curl -fsSL "$SENDNTFY_SRC" -o /tmp/sendntfy.sh
cp -- "$(readlink -f "$0")" /tmp/sendntfy.sh # this is just for prototyping for when i'm uh developing
if [[ ! -s /tmp/sendntfy.sh ]]; then
    echo "Failed to download update"
    ntf "Failed to download update"
    rm /tmp/sendntfy.sh
fi
if cmp -s '/tmp/sendntfy.sh' "$(readlink -f "$0")"; then
    echo "Up to date"
else
    #diff --color=always '/tmp/spymypc.sh' "$(readlink -f "$0")" | less -R
    echo "Updating"
    ntf "Updating"
    cp /tmp/sendntfy.sh "$0.tmp" &&
    chmod +x "$0.tmp" &&
    mv "$0.tmp" "$0" &&
    rm /tmp/sendntfy.sh &&
    exec $0 $@
fi

# Main

if [[ "$SENDNTFY_CONTENT" == "" ]]; then
    printf '\e[8;12;40t'
    tput clear
    echo "+======================================+"
    echo "|                                      |"
    echo "|                                      |"
    echo "|                                      |"
    echo "|                                      |"
    echo "|                                      |"
    echo "|                                      |"
    echo "|                                      |"
    echo "|                                      |"
    echo "|                                      |"
    echo "|                                      |"
    printf "+======================================+"
    tput cup 4 2
    read -rp "> " SENDNTFY_CONTENT
    tput cup 6 2
    read -rp "prio> " SENDNTFY_PRIO
    if [[ $SENDNTFY_URL == "" ]]; then
        tput cup 8 2
        read -rp "url> " SENDNTFY_URL
    fi

    tput clear
fi

SENDNTFY_RESP=$(curl -sS \
    -w '|||%{http_code}' \
    -H "Authorization: Bearer $SENDNTFY_TOKEN" \
    -H "X-Title: $(hostname)" \
    -H "X-Priority: $SENDNTFY_PRIO" \
    "$SENDNTFY_URL" \
    -d "$SENDNTFY_CONTENT")

SENDNTFY_LASTEXIT="$?"
SENDNTFY_STATUS=${SENDNTFY_RESP##*|||}
SENDNTFY_BODY=${SENDNTFY_RESP%|||*}


if [ "$SENDNTFY_LASTEXIT" != 0 ]; then
    ntf "Exit code was $SENDNTFY_LASTEXIT." "$SENDNTFY_RESP"
    echo "Exit code was $SENDNTFY_LASTEXIT"
    echo "$SENDNTFY_RESP"
else 
    if [ "$SENDNTFY_STATUS" -eq 200 ]; then
        ntf "OK" "sent"
        echo "OK sent"
        kill -9 "$PPID"
        #exit
    else
        ntf "Failed" "$SENDNTFY_RESP"
        echo "$SENDNTFY_RESP"
    fi
fi