#!/bin/bash

function broadcast {
    cd $GSSHMNT
    echo === gSsh ===
    echo
    echo "=== BROADCASTING (on "$GSSHMNT") ==="

    while true; do
        read -p "> " GSSHCMD
        echo $GSSHCMD > Prenos
        echo > new
        sleep 1
        rm -f new
        sleep 1
    done
}
function listen {
    cd $GSSHMNT
    echo === gSsh ===
    echo
    echo "=== LISTENING (on "$GSSHMNT") ==="
    
    while true; do
        if test -e new; then
            read GSSHCMD< Prenos
            $GSSHCMD
            sleep 2
        fi
    done
}

echo please mount a network drive that 
echo you have read + write access to
if [ $(whoami) == root ]; then
echo $( tput setaf 5 )you are root
else
tput setaf 3
echo "╔════════════════════════════════════════╗"
echo "║ WARNING!! in testing i had to run this ║"
echo "║ script with sudo in order for it       ║"
echo "║ to have permissions to write to        ║"
echo "║ the network drive                      ║"
echo "║ "$( tput setaf 10 )this only applies to broadcast mode$( tput setaf 3 )"    ║"
echo "╚════════════════════════════════════════╝"
fi
tput sgr0
read -p "Network drive path: " GSSHMNT

read -p "Mode: (LISTEN or BROADCAST)> " GSSHMODE

GSSHMODEFRMT=$(echo "${GSSHMODE}" | tr '[:upper:]' '[:lower:]')
if [ $GSSHMODEFRMT == "broadcast" ]; then
    broadcast
    exit
elif [ $GSSHMODEFRMT == "listen" ]; then
    listen
    exit
else
    echo unknown option
    echo please re-run this script to 
    echo change the option
    read -n 1 -s -r -p "Press any key to continue..."
fi
