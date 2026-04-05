#!/bin/bash

# --- Configuration ---
# Get the directory where the script is located to ensure paths are absolute
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/Config"
BACKUP_DIR="$HOME/.config/hypr_backup_$(date +%Y%m%d_%H%M%S)"

# Package Lists
PACMAN_PKG="$SCRIPT_DIR/pkg.txt"
YAY_PKG="$SCRIPT_DIR/yay.txt"

echo "Starting installation for AB..."

# 1. Install Base Dependencies & Pacman Packages
if [ -f "$PACMAN_PKG" ]; then
    echo "Updating system and installing official packages..."
    sudo pacman -Syu --needed base-devel git - < "$PACMAN_PKG"
else
    echo "Error: $PACMAN_PKG not found."
    exit 1
fi

# 2. Bootstrap YAY
if ! command -v yay &> /dev/null; then
    echo "🐣 Yay not found. Bootstrapping Yay from AUR..."
    TEMP_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$TEMP_DIR"
    cd "$TEMP_DIR" || exit
    # makepkg handles the build; -si installs and cleans up dependencies
    makepkg -si --noconfirm
    cd "$SCRIPT_DIR" || exit
    rm -rf "$TEMP_DIR"
else
    echo "Yay is already installed."
fi

# 3. Install AUR Packages
if [ -f "$YAY_PKG" ]; then
    echo "Installing AUR packages via yay..."
    yay -S --needed --noconfirm - < "$YAY_PKG"
else
    echo "$YAY_PKG not found, skipping AUR install."
fi

# 4. Setup Configs
echo "Backing up existing configs to $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

if [ -d "$SOURCE_DIR" ]; then
    cd "$SOURCE_DIR" || exit
    for dir in *; do
        if [ -d "$dir" ]; then
            TARGET="$HOME/.config/$dir"
            
            # If the target exists (file or link), move it to backup
            if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
                mv "$TARGET" "$BACKUP_DIR/"
            fi
            
            # Create symbolic link
            echo "Linking: $dir -> $TARGET"
            ln -s "$SOURCE_DIR/$dir" "$TARGET"
        fi
    done
else
    echo "Error: Config directory not found at $SOURCE_DIR"
    exit 1
fi

echo "-------------------------------------------"
echo "Setup complete"
echo "System will reboot in 10 seconds..."
echo "Press Ctrl+C to cancel reboot and check logs."
echo "-------------------------------------------"

# 5. Countdown and Reboot
sleep 10
echo "Rebooting now..."
sudo reboot now