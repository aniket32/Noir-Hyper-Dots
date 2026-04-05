#!/bin/bash

status=$(playerctl status 2>/dev/null)

title=$(playerctl metadata title 2>/dev/null)
artist=$(playerctl metadata artist 2>/dev/null)

if [ -z "$status" ]; then
    echo "No media"
    exit 0
fi

if [ "$status" == "Playing" ]; then
    icon="󰏤"   
else
    icon=""   
fi

if [ -n "$title" ] && [ -n "$artist" ]; then
    echo "$icon $artist - $title"
else
    echo "$icon"
fi

