#!/bin/bash

# Get the directory where the script is located to ensure paths are absolute
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/Config"
BACKUP_DIR="$HOME/.config/hypr_backup_$(date +%Y%m%d_%H%M%S)"

# Package Lists
PACMAN_PKG="$SCRIPT_DIR/pkg.txt"
YAY_PKG="$SCRIPT_DIR/yay.txt"

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

echo "Setup complete"
echo "System will reboot in 10 seconds..."
echo "Press Ctrl+C to cancel reboot and check logs."



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

    # Optional: enable power management daemon
    if systemctl list-unit-files | grep -q "^power-profiles-daemon"; then
        echo "Enabling power-profiles-daemon..."
        sudo systemctl enable power-profiles-daemon
        sudo systemctl start power-profiles-daemon
    fi

}

post_install

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