#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}[+] Setting up UI (Themes, Icons, Fonts)...${NC}"

# 1. Dependencies
echo "Installing UI dependencies..."
sudo apt-get install -y gtk2-engines-murrine gnome-tweaks gnome-shell-extension-manager libglib2.0-dev-bin dconf-editor

# 2. Themes (WhiteSur)
THEME_DIR="$HOME/.themes"
ICON_DIR="$HOME/.icons"
mkdir -p "$THEME_DIR" "$ICON_DIR"

echo "Installing WhiteSur GTK Theme..."
WORK_DIR=$(mktemp -d)
git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git "$WORK_DIR/WhiteSur-gtk-theme"
"$WORK_DIR/WhiteSur-gtk-theme/install.sh" -d "$THEME_DIR"

# 3. Icons (Tela Circle)
echo "Installing Tela Circle Icons..."
git clone https://github.com/vinceliuice/Tela-circle-icon-theme.git "$WORK_DIR/Tela-circle-icon-theme"
"$WORK_DIR/Tela-circle-icon-theme/install.sh" -d "$ICON_DIR"

# Cleanup
rm -rf "$WORK_DIR"

# 4. Fonts (Nerd Fonts - JetBrains Mono)
echo "Installing JetBrains Mono Nerd Font..."
mkdir -p "$HOME/.local/share/fonts"
cd "$HOME/.local/share/fonts"
if [ ! -f "JetBrainsMonoNerdFont-Regular.ttf" ]; then
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
    unzip -o JetBrainsMono.zip
    rm JetBrainsMono.zip
    fc-cache -fv
fi

# 5. Set Interface Settings (Dark Mode)
echo "Applying Interface Settings..."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark"
gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-dark"
# Note: User shell theme needs 'User Themes' extension enabled to work fully

echo -e "${GREEN}[+] UI Setup Complete!${NC}"
