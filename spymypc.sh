#!/usr/bin/env bash

# Todo: rewrite this to look & work better lol

CONFIGLOC="$HOME/.spymypc.conf"

toolErr() {
    echo "$1 doesn't exist"
    echo "please install or edit source"
    echo "to use a tool of your choice"
    exit 1
}
SMP_SOURCE="https://github.com/MrTomiCZ/simplebashscripts/raw/refs/heads/main/spymypc.sh"
SMP_FORMATTING="CLASSIC"
SMP_DEPS=('curl' 'less' 'cat' 'diff' 'cmp' 'tput' 'sed' 'readlink' 'rm' 'mv' 'cp' 'chmod' 'tr' 'mkdir' 'date')
# deps
for item in "${SMP_DEPS[@]}"; do
    #echo "checking if $item"
    if command -v "$item" >/dev/null 2>&1; then
        :
    else
        toolErr "$item"
    fi
done

GETWINCMD="kdotool getactivewindow getwindowname"
OLDTOKENLOC="$HOME/.spymypc.token"
OLDURLLOC="$HOME/.spymypc.url"

oldConfigMigration() {
    # Create backup in temp
    local tmp_dir="${TMPDIR:-/tmp}/spymypc_backup_$(date +%s)"
    mkdir -p "$tmp_dir"
    if ! cp "$OLDTOKENLOC" "$OLDURLLOC" "$tmp_dir/" 2>/dev/null; then
        echo "Warning: Failed to back up old configuration files to $tmp_dir." >&2
        read -p "Continue the migration without a backup? [yN] " continue_yn
        case "$continue_yn" in
            [Yy]*) ;;
            *) echo "Migration aborted."; return 1 ;;
        esac
    else
        echo "Backup created at: $tmp_dir"
    fi
    
    # migrate
    local token_old_val=""
    local url_old_val=""
    [[ -f "$OLDTOKENLOC" ]] && token_old_val=$(tr -d '\r\n' < "$OLDTOKENLOC")
    [[ -f "$OLDURLLOC" ]] && url_old_val=$(tr -d '\r\n' < "$OLDURLLOC")
    
    # IMPORTANT, DO NOT USE INDITATION (IDK HOW TO SPELL) DOWN HERE
    cat <<EOF > "$CONFIGLOC"
TOKEN=$token_old_val
URL=$url_old_val
EOF

    rm -f "$OLDTOKENLOC" "$OLDURLLOC"
    echo "Migration complete."
}

if [[ -f "$OLDTOKENLOC" || -f "$OLDURLLOC" ]]; then
    read -p "Old config system was found, would you like to migrate? [yn] " updateoldconfigyn
    while [[ true ]]; do
    case "$updateoldconfigyn" in
        [Yy]) 
            oldConfigMigration
            break
            ;;
        [Nn]) 
            echo "Not auto updating."
			echo "Use of old config was deleted"
			echo "and i'm lazy to bring it back lol"
			echo "it will be in a future update dw"
            break
            ;;
        *) 
            echo "invalid"
            ;;
    esac
done
fi


# Create new config if doesn't already exists
if [[ ! -f "$CONFIGLOC" ]]; then
    cat <<EOF > "$CONFIGLOC"
TOKEN=
URL=
EOF
    echo "Config file not found. Created template at $CONFIGLOC, please insert your own token (optional) and URL." >&2
    exit 1
fi

# Load config
declare -A config
while IFS='=' read -r key value || [ -n "$key" ]; do
    [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
    config["$key"]="$(echo "$value" | tr -d '\r')"
done < $CONFIGLOC

URL="${config[URL]}"
TOKEN="${config[TOKEN]}"


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
    # Mac added with the help of jpman (jpman.eu)
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
TEMPFILE="${TMPDIR:-/tmp}/spymypc.sh"
CURRFILE="$(readlink -f "$0")"
curl -fsSL https://github.com/MrTomiCZ/simplebashscripts/raw/refs/heads/main/spymypc.sh -o "$TEMPFILE"
if [[ ! -s "$TEMPFILE" ]]; then
    echo "Failed to download update"
    rm "$TEMPFILE"
fi
if cmp -s "$TEMPFILE" "$CURRFILE"; then
    echo "Up to date"
    rm "$TEMPFILE"
else
    diff --color=always "$TEMPFILE" "$CURRFILE" | less -R

    while true; do
        read -p "Update? [yn] " answer

        case "$answer" in
            [Yy])
                echo "Updating"
                cp "$TEMPFILE" "$CURRFILE.tmp" &&
                chmod +x "$CURRFILE.tmp" &&
                mv "$CURRFILE.tmp" "$CURRFILE" &&
                rm "$TEMPFILE" &&
                exec "$CURRFILE" $*
                break
                ;;
            [Nn])
                echo "alr not updating"
                rm "$TEMPFILE"
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

