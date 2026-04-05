#!/bin/bash

# Configuration
SOURCE_DIR="$(pwd)/Config"
BACKUP_DIR="$HOME/.config/hypr_backup_$(date +%Y%m%d_%H%M%S)"
PKG_FILE="pkg.txt"

# Determine package manager (yay is preferred for Hyprland ecosystems)
if command -v yay &> /dev/null; then
    AUR_HELPER="yay"
else
    AUR_HELPER="sudo pacman"
fi

echo "🚀 Starting installation for AB..."

# 1. Install Packages
if [ -f "$PKG_FILE" ]; then
    echo "📦 Installing explicit packages via $AUR_HELPER..."
    $AUR_HELPER -S --needed - < "$PKG_FILE"
else
    echo "❌ Error: $PKG_FILE not found."
    exit 1
fi

# 2. Setup Configs
echo "📂 Backing up existing configs to $BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

cd "$SOURCE_DIR" || exit
for dir in *; do
    if [ -d "$dir" ]; then
        TARGET="$HOME/.config/$dir"
        
        # If the target exists, move it to backup
        if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
            mv "$TARGET" "$BACKUP_DIR/"
        fi
        
        # Create symbolic link
        echo "🔗 Linking: $dir -> $TARGET"
        ln -s "$SOURCE_DIR/$dir" "$TARGET"
    fi
done

echo "✅ Setup complete, G. Ready for a reboot."
