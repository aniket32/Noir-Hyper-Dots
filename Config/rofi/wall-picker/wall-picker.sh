#!/bin/bash

# -----------------------------
# Rofi Wallpaper Picker for Hyprland
# -----------------------------

# Absolute path to your wallpaper directory
WALLPAPER_DIR="$HOME/.config/rofi/wallpaper"

# Ensure wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "Wallpaper directory not found: $WALLPAPER_DIR"
    exit 1
fi

# 1. Generate the list for Rofi with icons
rofi_input=""
while IFS= read -r wp; do
    filename=$(basename "$wp")
    rofi_input+="${filename}\0icon\x1f${wp}\n"
done < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | sort)

# Exit if no wallpapers found
if [ -z "$rofi_input" ]; then
    notify-send "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# 2. Show Rofi menu
# Using echo -en to interpret the hex escape characters (\0 and \x1f)
selected=$(echo -en "$rofi_input" | rofi -dmenu \
    -theme ~/.config/rofi/wall-picker/mono.rasi \
    -i -p "Select Wallpaper")

# 3. Apply selection
if [ -n "$selected" ]; then
    selected_path="$WALLPAPER_DIR/$selected"

    # Set wallpaper using swww
    if command -v awww >/dev/null 2>&1; then
        awww img "$selected_path"
    else
        notify-send "awww not found, cannot set wallpaper"
    fi
fi