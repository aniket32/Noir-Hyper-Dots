#!/bin/bash

# Pacman updates
pac_list=$(checkupdates 2>/dev/null)
pac=$(echo "$pac_list" | grep -c . || echo 0)

# AUR updates
if command -v yay >/dev/null; then
	aur_list=$(yay -Qua 2>/dev/null)
	aur=$(echo "$aur_list" | grep -c . || echo 0)
else
	aur=0
fi

# Flatpak updates
if command -v flatpak >/dev/null; then
	flat_list=$(flatpak remote-ls --updates 2>/dev/null)
	flat=$(echo "$flat_list" | grep -c . || echo 0)
else
	flat=0
fi

# Total
total=$((pac + aur + flat))

# Tooltip
tooltip=""
[ "$pac" -gt 0 ] && tooltip+="󰮯 Pacman ($pac):\n$(echo "$pac_list" | head -n 10)\n\n"
[ "$aur" -gt 0 ] && tooltip+=" AUR ($aur):\n$(echo "$aur_list" | head -n 10)\n\n"
[ "$flat" -gt 0 ] && tooltip+="󰏓 Flatpak ($flat):\n$(echo "$flat_list" | head -n 10)"


tooltip_json=$(printf "%s" "$tooltip" | jq -Rs .)

if [ "$total" -eq 0 ]; then
	printf '{"text": "", "alt": "empty", "tooltip": ""}\n'
else
	printf '{"text": "%s", "alt": "updates", "tooltip": %s}\n' "$total" "$tooltip_json"
fi
