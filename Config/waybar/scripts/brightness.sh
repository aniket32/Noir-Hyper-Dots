#!/bin/bash

CACHE_FILE="/tmp/brightness_value"

get_brightness() {
    local res
    res=$(ddcutil getvcp 10 --brief | awk '{print $4}' | tr -d ',')
    if [ -z "$res" ]; then
        res=0
    fi
    echo "$res"
}

if [ -f "$CACHE_FILE" ]; then
    cached=$(cat "$CACHE_FILE")
else
    cached=""
fi

current=$(get_brightness)

if [ "$current" != "$cached" ]; then
    echo "$current" > "$CACHE_FILE"
fi

echo "{\"text\": \"$current%\", \"percentage\": $current}"