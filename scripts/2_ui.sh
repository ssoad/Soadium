#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

# Load pinned stable versions
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../versions.env"

echo -e "${GREEN}[+] Setting up UI (Themes, Icons, Fonts) from stable releases...${NC}"

# Clone a repo at its latest stable tag (falls back to default branch if untagged)
clone_stable() {
    local repo_url=$1
    local dest=$2
    local latest_tag
    latest_tag=$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='-v:refname' "$repo_url" \
        | head -n1 | sed 's|.*refs/tags/||; s|\^{}||')
    if [ -n "$latest_tag" ]; then
        echo "  -> Using stable release tag: $latest_tag"
        git clone --depth 1 --branch "$latest_tag" "$repo_url" "$dest"
    else
        echo "  -> No release tags found, using default branch"
        git clone --depth 1 "$repo_url" "$dest"
    fi
}

# 1. Dependencies
echo "Installing UI dependencies..."
sudo apt-get install -y gtk2-engines-murrine gnome-tweaks gnome-shell-extension-manager libglib2.0-dev-bin dconf-editor sassc

# 2. Themes (WhiteSur, latest stable release)
THEME_DIR="$HOME/.themes"
ICON_DIR="$HOME/.icons"
mkdir -p "$THEME_DIR" "$ICON_DIR"

WORK_DIR=$(mktemp -d)

echo "Installing WhiteSur GTK Theme..."
clone_stable https://github.com/vinceliuice/WhiteSur-gtk-theme.git "$WORK_DIR/WhiteSur-gtk-theme"
"$WORK_DIR/WhiteSur-gtk-theme/install.sh" -d "$THEME_DIR"

# 3. Icons (Tela Circle, latest stable release)
echo "Installing Tela Circle Icons..."
clone_stable https://github.com/vinceliuice/Tela-circle-icon-theme.git "$WORK_DIR/Tela-circle-icon-theme"
"$WORK_DIR/Tela-circle-icon-theme/install.sh" -d "$ICON_DIR"

# Cleanup
rm -rf "$WORK_DIR"

# 4. Fonts (Nerd Fonts - JetBrains Mono, pinned stable release)
echo "Installing $NERD_FONT_NAME Nerd Font $NERD_FONT_VERSION..."
mkdir -p "$HOME/.local/share/fonts"
cd "$HOME/.local/share/fonts"
if [ ! -f "JetBrainsMonoNerdFont-Regular.ttf" ]; then
    wget "https://github.com/ryanoasis/nerd-fonts/releases/download/$NERD_FONT_VERSION/$NERD_FONT_NAME.zip"
    unzip -o "$NERD_FONT_NAME.zip"
    rm "$NERD_FONT_NAME.zip"
    fc-cache -fv
fi

# 5. Set Interface Settings (Dark Mode)
echo "Applying Interface Settings..."
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark"
gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-dark"
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 11'
# Note: User shell theme needs 'User Themes' extension enabled to work fully

echo -e "${GREEN}[+] UI Setup Complete!${NC}"
