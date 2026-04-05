#!/bin/bash

CURRENT_STATE=$(iwctl station wlan0 show | grep "Powered" | awk '{print $2}' | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

if [[ "$CURRENT_STATE" == "on" ]]; then
    iwctl station wlan0 set-property Powered off
else
    iwctl station wlan0 set-property Powered on
fi