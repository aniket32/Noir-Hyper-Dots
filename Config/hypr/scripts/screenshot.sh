#!/bin/bash

# Select region
region=$(slurp)

# Generate filename
filename=~/Pictures/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png

# Take screenshot
grim -g "$region" "$filename"

# Copy to clipboard
grim -g "$region" - | wl-copy

# Send Dunst notification
notify-send "Screenshot saved" "$filename" -i "$filename"