#!/bin/bash
while [ true ]; do
    LASTSTATE="run"
    SYRYAL="nothankyou"
    if [ "$(lsblk -o SERIAL -d | grep $SYRYAL --color=never)" == "$SYRYAL" ]; then
#        echo "IN"
        if [ $LASTSTATE != "in" ]; then
            loginctl unlock-session 2
        fi
        LASTSTATE="in"
    else
        echo "OUT, locking if unlocked"
        #if [ $LASTSTATE != "out" ]; then
            loginctl lock-session 2
        #fi
        LASTSTATE="out"
    fi
    #sleep 10
done
