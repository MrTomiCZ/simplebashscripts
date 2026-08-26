#!/usr/bin/env bash
toolErr() {
    echo "$1 doesn't exist"
    echo "please install or edit source"
    echo "to use a tool of your choice"
    exit 1
}
SMP_SOURCE="https://github.com/MrTomiCZ/simplebashscripts/raw/refs/heads/main/spymypc.sh"
SMP_FORMATTING="CLASSIC"
SMP_DEPS=('curl' 'less' 'cat' 'diff' 'cmp' 'tput' 'sed' 'readlink' 'rm' 'mv' 'cp' 'chmod')
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
    printf "\n\nstopping wait\n" &
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

gnomeErr() {
    tput setaf 3
	echo "GNOME issue!"
    tput sgr0
    echo "for GNOME to let you spy on"
    echo "windows you have to enable"
    echo "insecure or dev or wtv mode"
    echo
    echo "open the run prompt (commonly bound to Alt+F2)"
    YXVCBF="$(tput setaf 4)lg$(tput sgr0)"
    echo "write '$YXVCBF' (as in looking glass)"
    echo "then paste this:"
    tput setaf 4
    echo "global.context.unsafe_mode = true"
    tput sgr0
    echo "OR go into $(tput setaf 4)Flags$(tput sgr0) > scroll all the way down > General > $(tput setaf 4)unsafe-mode$(tput sgr0)"
    echo "then enter and esc to exit"
    read -s -p "press enter when you're done"
    echo
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
elif [[ "$XDG_CURRENT_DESKTOP" == "GNOME" && "$XDG_SESSION_TYPE" == "wayland" ]];then
    if command -v gdbus >/dev/null 2>&1; then
        GETWINCMD='
            gdbus call --session
                --dest org.gnome.Shell
                --object-path /org/gnome/Shell
                --method org.gnome.Shell.Eval
                "global.display.focus_window.get_title()"
        '
        SMP_FORMATTING="GNOME"
    else
        toolErr gdbus
    fi
elif [[ "$XDG_SESSION_TYPE" == "x11" ]];then
    echo "X11 is experimental"
    if command -v xdotool >/dev/null 2>&1; then
        GETWINCMD="xdotool getactivewindow getwindowname"
    else
        toolErr xdotool
    fi
elif [[ "$XDG_SESSION_TYPE" == "aqua" || "$OSTYPE" == darwin* ]];then
    echo "MacOS is experimental"
	echo "$(tput setaf 3)Warning$(tput sgr0): you have to enable Terminal.app in the Accessibility settings ($(tput setaf 4)Privacy & Security$(tput sgr0) > $(tput setaf 4)Accessibility$(tput sgr0)) for osascript to work"
	if command -v osascript >/dev/null 2>&1; then
	    GETWINCMD='osascript -e '\''tell application "System Events" to get name of first process whose frontmost is true'\'''
	else
	    toolErr osascript
	fi
else
# Fallback checks if XDG_SESSION_TYPE is not set
    if [ -n "$WAYLAND_DISPLAY" ]; then
        echo "non KDE or GNOME Wayland is currently not supported"
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
		exit 1
    fi
fi

# Updater
curl -fsSL https://github.com/MrTomiCZ/simplebashscripts/raw/refs/heads/main/spymypc.sh -o /tmp/spymypc.sh
if [[ ! -s /tmp/spymypc.sh ]]; then
    echo "Failed to download update"
    rm /tmp/spymypc.sh
fi
if cmp -s '/tmp/spymypc.sh' "$(readlink -f "$0")"; then
    echo "Up to date"
    rm /tmp/spymypc.sh
else
    diff --color=always '/tmp/spymypc.sh' "$(readlink -f "$0")" | less -R

    while true; do
        read -p "Update? [yn] " answer

        case "$answer" in
            [Yy])
                echo "Updating"
                cp /tmp/spymypc.sh "$0.tmp" &&
                chmod +x "$0.tmp" &&
                mv "$0.tmp" "$0" &&
                rm /tmp/spymypc.sh &&
                exec "$0"
                break
                ;;
            [Nn])
                echo "alr not updating"
                rm /tmp/spymypc.sh
                break
                ;;
            *)
                echo "invalid"
                ;;
        esac
    done
fi


trap cleanup EXIT # INT TERM

# GNOME check
if [[ "$FORMATTING" == "GNOME" ]]; then
    ACTIVEWIN="$($GETWINCMD)"

    # Extract first field (true/false)
    status=$(echo "$ACTIVEWIN" | sed -E 's/^\((true|false),.*/\1/')
    # Extract second field (the value inside quotes)
    val=$(echo "$ACTIVEWIN" | sed -E 's/^\((true|false), '\''"(.*)"'\''\)/\2/')
    if [[ "$status" == "false" ]]; then
        gnomeErr
    fi
fi


sendWebhook "Started" "SpyMyPC is running at $USER@$HOSTNAME on $(uname), PID $$"
coproc spymypc { exec curl -NsS -H "Authorization: Bearer $TOKEN" "$URL/raw"; }
EMPLOYMENTPID=$spymypc_PID
ACTIVEWIN="$(eval $GETWINCMD)"
if [[ "$SMP_FORMATTING" == "GNOME" ]]; then
    # Extract first field (true/false)
    status=$(echo "$ACTIVEWIN" | sed -E 's/^\((true|false),.*/\1/')
    # Extract second field (the value inside quotes)
    val=$(echo "$ACTIVEWIN" | sed -E 's/^\((true|false), '\''"(.*)"'\''\)/\2/')
    if [[ "$status" == "false" ]]; then
        gnomeErr
    fi
    ACTIVEWIN="$val"
fi
while [ true ]; do
    CURRENTWIN="$(eval $GETWINCMD)"
    if [[ "$SMP_FORMATTING" == "GNOME" ]]; then
        # Extract first field (true/false)
        status=$(echo "$CURRENTWIN" | sed -E 's/^\((true|false),.*/\1/')
        # Extract second field (the value inside quotes)
        val=$(echo "$CURRENTWIN" | sed -E 's/^\((true|false), '\''"(.*)"'\''\)/\2/')
        if [[ "$status" == "false" ]]; then
            gnomeErr
        fi
        CURRENTWIN="$val"
    fi
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
	sleep 0.1 # not posix compliant but who gives a fuck (i dont)
done

