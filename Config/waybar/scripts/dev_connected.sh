#!/bin/bash

icon_mouse="󰍽"
icon_mouse_wired="󰍿"
icon_kb=""
icon_discharging="󰂂"

icon_batt_10="󰁺"
icon_batt_20="󰁻"
icon_batt_30="󰁼"
icon_batt_40="󰁽"
icon_batt_50="󰁾"
icon_batt_60="󰁿"
icon_batt_70="󰂀"
icon_batt_80="󰂁"
icon_batt_90="󰂂"
icon_batt_100="󰁹"

icon_batt_charge_10="󰢜"
icon_batt_charge_20="󰂆"
icon_batt_charge_30="󰂇"
icon_batt_charge_40="󰂈"
icon_batt_charge_50="󰢝"
icon_batt_charge_60="󰂉"
icon_batt_charge_70="󰢞"
icon_batt_charge_80="󰂊"
icon_batt_charge_90="󰂋"
icon_batt_charge_100="󰂅"

output_list=()
tooltip_list=()

devices=$(upower -e | grep -v 'DisplayDevice' 2>/dev/null)

found_g502=false
found_kb=false
if lsusb | grep -q "046d:c098"; then
    found_g502=true
else
    found_g502=false
fi

get_mouse_icon() {
    local pct=${1%\%}
    local state=$2

    if [[ "$state" == "charging" || "$state" == "pending-charge" ]]; then
        if (( pct <= 10 )); then
            echo "$icon_mouse $icon_batt_charge_10"
        elif (( pct <= 20 )); then
            echo "$icon_mouse $icon_batt_charge_20"
        elif (( pct <= 30 )); then
            echo "$icon_mouse $icon_batt_charge_30"
        elif (( pct <= 40 )); then
            echo "$icon_mouse $icon_batt_charge_40"
        elif (( pct <= 50 )); then
            echo "$icon_mouse $icon_batt_charge_50"
        elif (( pct <= 60 )); then
            echo "$icon_mouse $icon_batt_charge_60"
        elif (( pct <= 70 )); then
            echo "$icon_mouse $icon_batt_charge_70"
        elif (( pct <= 80 )); then
            echo "$icon_mouse $icon_batt_charge_80"
        elif (( pct <= 90 )); then
            echo "$icon_mouse $icon_batt_charge_90"
        else
            echo "$icon_mouse $icon_batt_charge_100"
        fi
    else
        # Discharging / normal battery icons
        if (( pct <= 10 )); then
            echo "$icon_mouse $icon_batt_10"
        elif (( pct <= 20 )); then
            echo "$icon_mouse $icon_batt_20"
        elif (( pct <= 30 )); then
            echo "$icon_mouse $icon_batt_30"
        elif (( pct <= 40 )); then
            echo "$icon_mouse $icon_batt_40"
        elif (( pct <= 50 )); then
            echo "$icon_mouse $icon_batt_50"
        elif (( pct <= 60 )); then
            echo "$icon_mouse $icon_batt_60"
        elif (( pct <= 70 )); then
            echo "$icon_mouse $icon_batt_70"
        elif (( pct <= 80 )); then
            echo "$icon_mouse $icon_batt_80"
        elif (( pct <= 90 )); then
            echo "$icon_mouse $icon_batt_90"
        else
            echo "$icon_mouse $icon_batt_100"
        fi
    fi
}

if [ -n "$devices" ]; then
    while read -r dev; do
        dev_info=$(upower -i "$dev")
        
        is_present=$(echo "$dev_info" | grep -i "present:" | awk '{print $2}')
        model=$(echo "$dev_info" | grep -i "model:" | cut -d':' -f2- | xargs)
        percentage=$(echo "$dev_info" | grep -i "percentage:" | awk '{print $2}')
        state=$(echo "$dev_info" | grep -i "state:" | awk '{print $2}' | tr '[:upper:]' '[:lower:]')

        if [[ "$is_present" == "yes" && -n "$percentage" && "$percentage" != "0%" ]]; then
            if [[ "$model" == *"G502"* ]]; then
                found_g502=true
                if [[ "$state" != "unknown" ]]; then
                    icon_with_charge=$(get_mouse_icon "$percentage" "$state")
                    output_list+=("$icon_with_charge")
                    tooltip_list+=("$model: $percentage")
                fi
                
            elif [[ "$model" == *"Hangsheng"* || "$dev" == *"keyboard"* ]]; then
                found_kb=true
                output_list+=("$icon_kb")
                tooltip_list+=("${model:-Keyboard}: $percentage")
            fi
        fi
    done <<< "$devices"
fi

if [ "$found_kb" = false ]; then
    if lsusb | grep -q "342d:e4c5"; then
        output_list+=("$icon_kb")
        tooltip_list+=("Hangsheng Keyboard: Connected")
    fi
fi
final_output_list=()
for item in "${output_list[@]}"; do
    [[ -n "$item" ]] && final_output_list+=("$item")
done

if [ ${#final_output_list[@]} -eq 0 ]; then
    echo '{"text": "", "tooltip": ""}'
else
    final_text=$(printf "%s\n" "${final_output_list[@]}" | sort -u | paste -sd "/" - | sed 's/\// \/ /g')
    final_tooltip=$(printf "%s\n" "${tooltip_list[@]}" | sort -u | paste -sd "\n" -)
    
    jq -nc --arg text "$final_text" --arg tooltip "$final_tooltip" \
        '{"text": $text, "tooltip": $tooltip}'
fi
