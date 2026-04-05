#!/bin/bash

CACHE_FILE="/tmp/brightness_value"

# Get all display numbers
DISPLAYS=$(ddcutil detect --brief | grep "Display" | awk '{print $2}')

get_average_brightness() {
    local total=0
    local count=0
    for disp in $DISPLAYS; do
        # Extract current value for each specific display
        val=$(ddcutil getvcp 10 --display "$disp" --brief | awk '{print $4}' | tr -d ',')
        if [[ "$val" =~ ^[0-9]+$ ]]; then
            total=$((total + val))
            count=$((count + 1))
        fi
    done
    
    if [ "$count" -gt 0 ]; then
        echo $((total / count))
    else
        echo 0
    fi
}

# Handle brightness adjustment if arguments are passed
if [ "$1" == "up" ]; then
    for disp in $DISPLAYS; do
        ddcutil setvcp 10 + 20 --display "$disp" --noverify &
    done
    wait
elif [ "$1" == "down" ]; then
    for disp in $DISPLAYS; do
        ddcutil setvcp 10 - 20 --display "$disp" --noverify &
    done
    wait
fi

current=$(get_average_brightness)
echo "$current" > "$CACHE_FILE"
echo "{\"text\": \"$current%\", \"percentage\": $current}"