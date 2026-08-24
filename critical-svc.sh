#!/bin/bash

# Author: mrtomicz
# WWW: mrtomicz.eu
# Dependencies: cat, cmp, cp, mv, rm, chmod, curl, coproc (bash >= 4.0), jq
# Relies on ntfy: docs.ntfy.sh

# journalctl --user -xeu attention-sound.service -- logs
# nano ~/.config/systemd/user/attention-sound.service -- svc
# nano ~/scripts/critical-svc.sh -- this

# Enable steps:
# systemctl --user daemon-reload
# systemctl --user enable --now attention-sound.service
# systemctl --user status attention-sound # should say running etc

ATT_URL="$(cat $HOME/.att.url)"
ATT_TOKEN="$(cat $HOME/.att.token)"
ATT_SRC="https://github.com/MrTomiCZ/simplebashscripts/raw/refs/heads/main/critical-svc.sh"

ntf() {
    notify-send --app-name=attention-sound --icon=/usr/share/icons/breeze/status/16/data-warning.svg --expire-time=5000 "$1" "$2"
    canberra-gtk-play -f /usr/share/sounds/oxygen/stereo/message-attention.ogg &
}

# Updater
curl -fsSL "$ATT_SRC" -o /tmp/critical-svc.sh
if [[ ! -s /tmp/critical-svc.sh ]]; then
    echo "Failed to download update"
    ntf "Failed to download update"
    rm /tmp/critical-svc.sh
fi
if cmp -s '/tmp/critical-svc.sh' "$(readlink -f "$0")"; then
    echo "Up to date"
else
    #diff --color=always '/tmp/spymypc.sh' "$(readlink -f "$0")" | less -R
    echo "Updating"
    ntf "Updating"
    cp /tmp/critical-svc.sh "$0.tmp" &&
    chmod +x "$0.tmp" &&
    mv "$0.tmp" "$0" &&
    rm /tmp/critical-svc.sh &&
    systemctl --user restart attention-sound.service
fi

coproc ATTS {
    exec curl -NsS -H "Authorization: Bearer $ATT_TOKEN" "$ATT_URL/json"
}

# Main/background work
while true; do
    if read -r -t 0.1 json <&"${ATTS[0]}"; then
        ATT_EVNT=$(jq -r '.event' <<< "$json")
        if [[ "$ATT_EVNT" == "message" ]]; then
            ATT_MSG=$(jq -r ".message" <<< "$json")
            if jq -e 'has("title")' <<< "$json" >/dev/null; then
                ATT_TTL=$(jq -r ".title" <<< "$json")
            else
                ATT_TTL=""
            fi
            ntf "$ATT_TTL" "$ATT_MSG"
        fi
    fi
    sleep 1
done
#canberra-gtk-play -f /usr/share/sounds/oxygen/stereo/message-attention.ogg

