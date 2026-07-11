#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$SCRIPT_DIR/.."

echo -e "${GREEN}[+] Applying Soadium identity (logo, wallpaper, prompt, splash)...${NC}"

# 1. Install brand assets
echo "Installing brand assets..."
sudo install -d /usr/share/soadium /usr/share/backgrounds/soadium
sudo install -m 644 "$REPO_DIR/branding/logo.svg"      /usr/share/soadium/logo.svg
sudo install -m 644 "$REPO_DIR/branding/logo-mark.svg" /usr/share/soadium/logo-mark.svg
sudo install -m 644 "$REPO_DIR/branding/wallpaper.svg" /usr/share/backgrounds/soadium/soadium-wallpaper.svg

# 2. soadium-fetch (terminal system info)
echo "Installing soadium-fetch..."
sudo install -m 755 "$REPO_DIR/bin/soadium-fetch" /usr/local/bin/soadium-fetch

# 3. Wallpaper (light + dark)
echo "Setting wallpaper..."
gsettings set org.gnome.desktop.background picture-uri "file:///usr/share/backgrounds/soadium/soadium-wallpaper.svg" || true
gsettings set org.gnome.desktop.background picture-uri-dark "file:///usr/share/backgrounds/soadium/soadium-wallpaper.svg" || true
gsettings set org.gnome.desktop.background picture-options 'zoom' || true
gsettings set org.gnome.desktop.background primary-color '#0B1021' || true

# 4. Dock favorites - a developer's launcher, nothing else
echo "Setting dock favorites..."
gsettings set org.gnome.shell favorite-apps \
    "['org.gnome.Nautilus.desktop', 'brave-browser.desktop', 'code_code.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Settings.desktop']" || true

# 5. Starship prompt theme
echo "Installing Soadium Starship theme..."
mkdir -p "$HOME/.config"
cp "$REPO_DIR/resources/starship/starship.toml" "$HOME/.config/starship.toml"

# 6. Terminal colors (Soadium dark palette for the default GNOME Terminal profile)
echo "Applying terminal palette..."
if command -v gsettings &> /dev/null; then
    PROFILE_ID=$(gsettings get org.gnome.Terminal.ProfilesList default 2>/dev/null | tr -d "'")
    if [ -n "$PROFILE_ID" ]; then
        P="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$PROFILE_ID/"
        gsettings set "$P" use-theme-colors false || true
        gsettings set "$P" background-color '#0B1021' || true
        gsettings set "$P" foreground-color '#E2E8F0' || true
        gsettings set "$P" bold-color-same-as-fg true || true
        gsettings set "$P" palette "['#0B1021', '#F87171', '#34D399', '#FACC15', '#818CF8', '#C084FC', '#22D3EE', '#E2E8F0', '#3B4368', '#F87171', '#34D399', '#FDE047', '#A5B4FC', '#D8B4FE', '#67E8F9', '#F8FAFC']" || true
        gsettings set "$P" font 'JetBrainsMono Nerd Font 12' || true
        gsettings set "$P" use-system-font false || true
    fi
fi

# 7. Plymouth boot splash (best effort - never break boot or the install)
echo "Installing Soadium boot splash..."
if command -v plymouth-set-default-theme &> /dev/null; then
    sudo apt-get install -y librsvg2-bin || true
    if command -v rsvg-convert &> /dev/null; then
        sudo install -d /usr/share/plymouth/themes/soadium
        sudo install -m 644 "$REPO_DIR/resources/plymouth/soadium.plymouth" /usr/share/plymouth/themes/soadium/
        sudo install -m 644 "$REPO_DIR/resources/plymouth/soadium.script"   /usr/share/plymouth/themes/soadium/
        rsvg-convert -w 220 -h 220 "$REPO_DIR/branding/logo-mark.svg" -o /tmp/soadium-logo.png \
            && sudo install -m 644 /tmp/soadium-logo.png /usr/share/plymouth/themes/soadium/logo.png \
            && rm -f /tmp/soadium-logo.png
        if [ -f /usr/share/plymouth/themes/soadium/logo.png ]; then
            sudo plymouth-set-default-theme soadium || true
            sudo update-initramfs -u || true
        fi
    fi
fi

echo -e "${GREEN}[+] Soadium Identity Applied! Try: soadium-fetch${NC}"
