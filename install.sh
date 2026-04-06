#!/bin/bash

# Get the directory where the script is located to ensure paths are absolute
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/Config"
BACKUP_DIR="$HOME/.config/hypr_backup_$(date +%Y%m%d_%H%M%S)"

# Package Lists
PACMAN_PKG="$SOURCE_DIR/pkg.txt"
YAY_PKG="$SOURCE_DIR/yay.txt"

echo "Starting installation for AB..."

# Install Base Dependencies & Pacman Packages
if [ -f "$PACMAN_PKG" ]; then
    echo "Updating system and installing official packages..."
    sudo pacman -Syu --needed base-devel git - < "$PACMAN_PKG"
else
    echo "Error: $PACMAN_PKG not found."
    exit 1
fi

# Bootstrap YAY
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

# Install AUR Packages
if [ -f "$YAY_PKG" ]; then
    echo "Installing AUR packages via yay..."
    yay -S --needed --noconfirm - < "$YAY_PKG"
else
    echo "$YAY_PKG not found, skipping AUR install."
fi

# Setup Configs
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

# Define Icon Variables
ICON_URL="https://bitbucket.org/dirn-typo/yet-another-monochrome-icon-set/get/main.tar.gz"
ICON_DEST="$HOME/.local/share/icons"

echo "Downloading and installing Yet Another Monochrome Icon Set..."
mkdir -p "$ICON_DEST"

# Use a temp directory to handle the dynamic folder name from Bitbucket
TEMP_ICON_DIR=$(mktemp -d)
curl -L "$ICON_URL" | tar -xz -C "$TEMP_ICON_DIR"

# Identify the extracted folder (it changes name based on the commit hash)
EXTRACTED_FOLDER=$(find "$TEMP_ICON_DIR" -maxdepth 1 -type d -name "dirn-typo-*" | head -n 1)

if [ -d "$EXTRACTED_FOLDER" ]; then
    # Move the contents of the extracted folder into ~/.local/share/icons
    cp -r "$EXTRACTED_FOLDER" "$ICON_DEST/YAM-Icons"
    echo "Icons installed to $ICON_DEST/YAM-Icons"
else
    echo "Error: Could not locate extracted icon folder."
fi

rm -rf "$TEMP_ICON_DIR"

echo "Icon set installed to $ICON_DEST"

# Post-install setup 
echo "Running post-install setup for services and additional configuration..."

post_install() {
    # Enable display manager
    if systemctl list-unit-files | grep -q "^sddm"; then
        echo "Enabling SDDM..."
        sudo systemctl enable sddm.service
        sudo systemctl start sddm.service
    fi
    # Enable NetworkManager
    if systemctl list-unit-files | grep -q "^NetworkManager"; then
        echo "Enabling NetworkManager..."
        sudo systemctl enable NetworkManager.service
        sudo systemctl start NetworkManager.service
    fi
    # Enable Bluetooth
    if systemctl list-unit-files | grep -q "^bluetooth"; then
        echo "Enabling Bluetooth..."
        sudo systemctl enable bluetooth.service
        sudo systemctl start bluetooth.service
    fi
    # Enable pipewire services
    echo "Enabling Pipewire services..."
    systemctl --user enable pipewire pipewire-pulse wireplumber
    systemctl --user start pipewire pipewire-pulse wireplumber

    # Enable power management daemon
    if systemctl list-unit-files | grep -q "^power-profiles-daemon"; then
        echo "Enabling power-profiles-daemon..."
        sudo systemctl enable power-profiles-daemon
        sudo systemctl start power-profiles-daemon
    fi

    # Install and Update XDG User Directories
    echo "Initializing XDG User Directories for Thunar..."
    if ! command -v xdg-user-dirs-update &> /dev/null; then
        sudo pacman -S --needed --noconfirm xdg-user-dirs
    fi
    xdg-user-dirs-update

    # Apply specific GTK Settings
    echo "Applying custom GTK settings..."
    for version in "3.0" "4.0"; do
        mkdir -p "$HOME/.config/gtk-$version"
        cat <<EOF > "$HOME/.config/gtk-$version/settings.ini"
[Settings]
gtk-theme-name=Adwaita
gtk-icon-theme-name=YAM-Icons
gtk-font-name=JetBrainsMono Nerd Font Ultra-Bold 11
gtk-cursor-theme-name=default
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintmedium
gtk-xft-rgba=rgb
gtk-application-prefer-dark-theme=1
gtk-decoration-layout=:
EOF
    done

    # Force an icon cache update for YAM-Icons
    if [ -d "$ICON_DEST/YAM-Icons" ]; then
        gtk-update-icon-cache -f -t "$ICON_DEST/YAM-Icons" > /dev/null 2>&1
    fi

    echo "GTK settings and YAM-Icons activated."

}

post_install

echo "Setup complete"
echo "System will reboot in 10 seconds..."
echo "Press Ctrl+C to cancel reboot and check logs."

#  Countdown and Reboot
sleep 10
echo "Rebooting now..."
sudo reboot now

# #!/bin/bash

# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# SOURCE_DIR="$SCRIPT_DIR/Config"
# BACKUP_DIR="$HOME/.config/hypr_backup_$(date +%Y%m%d_%H%M%S)"

# PACMAN_PKG="$SCRIPT_DIR/pkg.txt"
# YAY_PKG="$SCRIPT_DIR/yay.txt"

# echo "Starting installation for AB setup..."

# # Install Base Dependencies & Pacman Packages ---
# if [ -f "$PACMAN_PKG" ]; then
#     echo "Updating system and installing official packages..."
#     sudo pacman -Syu --needed base-devel git - < "$PACMAN_PKG"
# else
#     echo "Error: $PACMAN_PKG not found."
#     exit 1
# fi

# # Bootstrap Yay if missing ---
# if ! command -v yay &> /dev/null; then
#     echo "Yay not found. Bootstrapping Yay from AUR..."
#     TEMP_DIR=$(mktemp -d)
#     git clone https://aur.archlinux.org/yay.git "$TEMP_DIR"
#     cd "$TEMP_DIR" || exit
#     makepkg -si --noconfirm
#     cd "$SCRIPT_DIR" || exit
#     rm -rf "$TEMP_DIR"
# else
#     echo "Yay is already installed."
# fi

# #  Install AUR Packages ---
# if [ -f "$YAY_PKG" ]; then
#     echo "Installing AUR packages via yay..."
#     yay -S --needed --noconfirm - < "$YAY_PKG"
# else
#     echo "$YAY_PKG not found, skipping AUR install."
# fi

# # Post-install Service Setup ---
# echo "Enabling and starting system and user services..."

# # System services
# SYSTEM_SERVICES=(
#     sddm
#     NetworkManager
#     bluetooth
#     iwd
#     power-profiles-daemon
#     iptables
# )

# for svc in "${SYSTEM_SERVICES[@]}"; do
#     if systemctl list-unit-files | grep -q "^$svc"; then
#         echo "Enabling and starting $svc..."
#         sudo systemctl enable --now "$svc"
#     fi
# done

# # NVIDIA optional services
# NVIDIA_SERVICES=(
#     nvidia-suspend
#     nvidia-hibernate
#     nvidia-powersave
# )

# for svc in "${NVIDIA_SERVICES[@]}"; do
#     if systemctl list-unit-files | grep -q "^$svc"; then
#         echo "Enabling NVIDIA service $svc..."
#         sudo systemctl enable "$svc"
#     fi
# done

# # User services (Pipewire, udiskie)
# USER_SERVICES=(
#     pipewire
#     pipewire-pulse
#     wireplumber
#     udiskie
# )

# for svc in "${USER_SERVICES[@]}"; do
#     if systemctl --user list-unit-files | grep -q "^$svc"; then
#         echo "Enabling and starting user service $svc..."
#         systemctl --user enable --now "$svc"
#     fi
# done

# # Backup & Link Configs ---
# echo "Backing up existing configs to $BACKUP_DIR"
# mkdir -p "$BACKUP_DIR"

# if [ -d "$SOURCE_DIR" ]; then
#     cd "$SOURCE_DIR" || exit
#     for dir in *; do
#         if [ -d "$dir" ]; then
#             TARGET="$HOME/.config/$dir"
#             if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
#                 mv "$TARGET" "$BACKUP_DIR/"
#             fi
#             echo "Linking: $dir -> $TARGET"
#             ln -s "$SOURCE_DIR/$dir" "$TARGET"
#         fi
#     done
# else
#     echo "Error: Config directory not found at $SOURCE_DIR"
#     exit 1
# fi

# # Completion & Reboot ---
# echo "-------------------------------------------"
# echo "Setup complete. System will reboot in 10 seconds..."
# echo "Press Ctrl+C to cancel reboot and check logs."
# echo "-------------------------------------------"

# sleep 10
# sudo reboot now