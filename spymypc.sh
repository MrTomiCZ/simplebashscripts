#!/bin/bash
URL="https://ntfy.mtmi.eu/mt-cachy-spymypc"
ACTIVEWIN="$(kdotool getactivewindow getwindowname)"
TOKEN="no"
# project settings / envs / m / env secrets
while [ true ]; do
    CURRENTWIN="$(kdotool getactivewindow getwindowname)"
    if [[ "$CURRENTWIN" != "$ACTIVEWIN" && "$CURRENTWIN" != "" ]]; then
        curl -sS "$URL" -d "$CURRENTWIN" -H "Title: SpyMyPC: Active window changed" -H "Authorization: Bearer $TOKEN" > /dev/null
        ACTIVEWIN="$CURRENTWIN"
    fi
done
