#!/bin/bash

# Fetch updates
pac_list=$(checkupdates 2>/dev/null)
pac=$(echo "$pac_list" | grep -c . || echo 0)

if command -v yay >/dev/null; then
    aur_list=$(yay -Qua 2>/dev/null)
    aur=$(echo "$aur_list" | grep -c . || echo 0)
else
    aur=0
fi

if command -v flatpak >/dev/null; then
    flat_list=$(flatpak remote-ls --updates 2>/dev/null)
    flat=$(echo "$flat_list" | grep -c . || echo 0)
else
    flat=0
fi

total=$((pac + aur + flat))

# If no updates, exit with  to hide the pill in Waybar
if [ "$total" -eq 0 ]; then
    exit 0
fi

# Build tooltip with escaped newlines for JSON compatibility
tooltip=""
[ "$pac" -gt 0 ] && tooltip+="📦 Pacman ($pac):\n$(echo "$pac_list" | head -n 10 | sed ':a;N;$!ba;s/\n/\\n/g')\n\n"
[ "$aur" -gt 0 ] && tooltip+="✨ AUR ($aur):\n$(echo "$aur_list" | head -n 10 | sed ':a;N;$!ba;s/\n/\\n/g')\n\n"
[ "$flat" -gt 0 ] && tooltip+="🎁 Flatpak ($flat):\n$(echo "$flat_list" | head -n 10 | sed ':a;N;$!ba;s/\n/\\n/g')"

# Output JSON for Waybar
printf '{"text": "%s", "tooltip": "%s"}\n' "$total" "$tooltip"