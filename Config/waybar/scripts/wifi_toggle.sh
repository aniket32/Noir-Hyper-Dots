#!/bin/bash
# Get the current autoconnect status for wlan0
STATUS=$(iwctl station wlan0 show | grep "Autoconnect" | awk '{print $2}')

if [ "$STATUS" == "on" ]; then
    iwctl station wlan0 set-property Autoconnect off
    iwctl station wlan0 disconnect
else
    iwctl station wlan0 set-property Autoconnect on
fi