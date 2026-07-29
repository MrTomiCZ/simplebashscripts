#!/bin/bash
URL="https://ntfy.mtmi.eu/mt-cachy-spymypc"
ACTIVEWIN="$(kdotool getactivewindow getwindowname)"
TOKEN="no"
sendWebhook() {
    curl -sS "$URL" -d "$2" -H "Title: SpyMyPC: $1" -H "Authorization: Bearer $TOKEN" > /dev/null
}
cleanup() {
    sendWebhook "Stopped" "EXIT signal received: SpyMyPC closed."
    exit
}
trap cleanup EXIT


sendWebhook "Started" "SpyMyPC is running at $USER@$HOSTNAME"
while [ true ]; do
    CURRENTWIN="$(kdotool getactivewindow getwindowname)"
    if [[ "$CURRENTWIN" != "$ACTIVEWIN" && "$CURRENTWIN" != "" ]]; then
        sendWebhook "Active window changed" "$CURRENTWIN"
        ACTIVEWIN="$CURRENTWIN"
    fi
done
