#!/bin/bash

region=$(slurp)

if [ -z "$region" ]; then
    exit 0
fi

filename=~/Pictures/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png

grim -g "$region" "$filename"

grim -g "$region" - | wl-copy

notify-send "Screenshot saved" "$filename" -i "$filename"