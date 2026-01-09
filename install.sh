#!/bin/bash
set -e

# Soadium OS Installer
# A Custom Developer-Focused Ubuntu Configuration

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo -e "${BLUE}"
echo "   _____   ____  ___    ____  ____  __  ____  ___ "
echo "  / ___/  / __ \/   |  / __ \/  _/ / / / /  |/  / "
echo "  \__ \  / / / / /| | / / / // /  / / / / /|_/ /  "
echo " ___/ / / /_/ / ___ |/ /_/ // /  / /_/ / /  / /   "
echo "/____/  \____/_/  |_/_____/___/  \____/_/  /_/    "
echo "                                                  "
echo -e "${NC}"
echo "Welcome to Soadium OS Installer."
echo "This will modify your system configurations, install packages, and change themes."
echo "Please ensure you have internet connection and sudo privileges."
echo ""
read -p "Press [Enter] to continue or Ctrl+C to abort..."
echo ""

# Check Sudo
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOG_FILE="$SCRIPT_DIR/install.log"

echo -e "${BLUE}[*] Starting Installation... Logs at $LOG_FILE${NC}"

# Function to run scripts
run_script() {
    local script_name=$1
    echo -e "${BLUE}[*] Running $script_name...${NC}"
    chmod +x "$SCRIPT_DIR/scripts/$script_name"
    if "$SCRIPT_DIR/scripts/$script_name" >> "$LOG_FILE" 2>&1; then
        echo -e "${GREEN}[✓] $script_name completed successfully.${NC}"
    else
        echo -e "${RED}[X] $script_name failed! Check $LOG_FILE for details.${NC}"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

run_script "0_privacy.sh"
run_script "1_dev_ai.sh"
run_script "2_ui.sh"
run_script "3_shell.sh"
run_script "4_gnome.sh"

echo ""
echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}   Soadium OS Installation Complete!       ${NC}"
echo -e "${GREEN}===========================================${NC}"
echo "It is highly recommended to REBOOT your system now."
echo ""
read -p "Reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo reboot
fi
