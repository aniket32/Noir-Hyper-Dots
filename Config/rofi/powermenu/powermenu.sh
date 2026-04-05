#!/usr/bin/env bash

# Toggle Logic: If rofi is already running, kill it and exit
if pgrep -x "rofi" > /dev/null; then
    pkill -x "rofi"
    exit 0
fi

# Current Theme
dir="$HOME/.config/rofi/powermenu/"
theme='style'

# CMDs
uptime="`uptime -p | sed -e 's/up //g'`"
host=$(cat /etc/hostname)

# Options
shutdown=''
reboot=''
lock=''
suspend='󰤄'
logout='󰍃'
yes='󰄬' 
no='󰅖'


instant_flags=(
    -hover-select
    -me-select-entry '' 
    -me-accept-entry MousePrimary
)

# Rofi Main Menu CMD
rofi_cmd() {
    rofi -dmenu \
        -p "Uptime: $uptime" \
        -mesg "Uptime: $uptime" \
        -theme "${dir}/${theme}.rasi" \
        "${instant_flags[@]}"
}

# Confirmation CMD
confirm_cmd() {
    rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px; border: 0px; border-color: @selected; border-radius: 20px;}' \
        -theme-str 'mainbox {children: [ "message", "listview" ];}' \
        -theme-str 'listview {columns: 2; lines: 1;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'textbox {horizontal-align: 0.5;}' \
        -dmenu \
        -p 'Confirmation' \
        -mesg 'Are you Sure?' \
        -theme "${dir}/${theme}.rasi" \
        "${instant_flags[@]}"
}

# Ask for confirmation
confirm_exit() {
	echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
	echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
	selected="$(confirm_exit)"
	if [[ "$selected" == "$yes" ]]; then
		if [[ $1 == '--shutdown' ]]; then
			systemctl poweroff
		elif [[ $1 == '--reboot' ]]; then
			systemctl reboot
        elif [[ $1 == '--suspend' ]]; then
                    mpc -q pause
                    amixer set Master mute
                    hyprlock --grace 0 & 
                    sleep 0.5 
                    systemctl suspend
        elif [[ "$XDG_SESSION_TYPE" == 'wayland' && "$DESKTOP_SESSION" == 'hyprland' ]]; then
            mpc -q pause
            amixer set Master mute
            hyprctl dispatch exit
		fi
	else
		exit 0
	fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
		run_cmd --shutdown
        ;;
    $reboot)
		run_cmd --reboot
        ;;
    $lock)
        hyprlock --grace 0
        ;;
    $suspend)
		run_cmd --suspend
        ;;
    $logout)
		run_cmd --logout
        ;;
esac
