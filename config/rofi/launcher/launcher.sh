#!/usr/bin/env bash

dir="$HOME/.config/rofi/launcher/"
theme='mono'

## Run
rofi \
    -show drun \
    -theme ${dir}/${theme}.rasi
