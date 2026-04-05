#!/usr/bin/env bash

dir="$HOME/.config/rofi/launcher/"
theme='mono'

# Get current wallpaper from awww
CUR_IMG=$(awww query | grep -m1 "image:" | awk '{print $NF}')

# Run Rofi with dynamic background image
rofi \
    -show drun \
    -theme ${dir}/${theme}.rasi \
    -theme-str "imagebox { background-image: url('$CUR_IMG', height); }"