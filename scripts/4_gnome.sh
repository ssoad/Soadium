#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}[+] Configuring GNOME Desktop...${NC}"

# 1. Dock Settings (Ubuntu Dock)
echo "Configuring Dock..."
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48
gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
# Center the dock (requires dash-to-dock to be active)

# 2. Window Management
echo "Configuring Window Management..."
gsettings set org.gnome.desktop.wm.preferences action-middle-click-titlebar 'minimize'
gsettings set org.gnome.mutter center-new-windows true
gsettings set org.gnome.desktop.interface enable-hot-corners true

# 3. Workspaces
echo "Configuring Workspaces..."
gsettings set org.gnome.mutter dynamic-workspaces true
gsettings set org.gnome.desktop.wm.preferences num-workspaces 4

# 4. Keyboard Shortcuts for Developers
echo "Setting up Developer Shortcuts..."
# Ctrl+Alt+T is default for terminal, make sure it's set
gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Primary><Alt>t']"

echo -e "${GREEN}[+] GNOME Configuration Applied!${NC}"
