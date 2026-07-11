#!/bin/bash
set -e

# Soadium OS Installer
# A clean, stable, developer-first Ubuntu configuration.

# Brand colors (256-color with plain fallback handled by terminals)
IR='\033[38;5;99m'    # Iris
IL='\033[38;5;111m'   # Iris light
CY='\033[38;5;51m'    # Electron cyan
FL='\033[38;5;220m'   # Sodium flame
TX='\033[38;5;253m'   # Text
MU='\033[38;5;244m'   # Muted
GR='\033[38;5;114m'   # Success green
RD='\033[38;5;203m'   # Error red
BD='\033[1m'
NC='\033[0m'

clear
echo
echo -e "  ${IR}    ▗▄▄▄▄▄▄▄▄▖${NC}"
echo -e "  ${IR}   ▟▛        ▜▙${NC}"
echo -e "  ${IL}  ▟▛   ${FL}▄▄▄▄${IL}   ▜▙${NC}       ${BD}${TX}S O A D I U M   O S${NC}"
echo -e "  ${IL} ▐▌    ${FL}█▄▄▄${IL}    ▐▌${NC}"
echo -e "  ${CY} ▐▌    ${FL}▄▄▄█${CY}    ▐▌${NC}      ${MU}Developer-first · Stable · Clean${NC}"
echo -e "  ${CY}  ▜▙   ${FL}▀▀▀▀${CY}   ▟▛${NC}       ${MU}Na · 11 · github.com/ssoad/Soadium${NC}"
echo -e "  ${CY}   ▜▙        ▟▛${NC}"
echo -e "  ${CY}    ▝▀▀▀▀▀▀▀▀▘  ${FL}●${NC}"
echo
echo -e "  ${TX}This will install packages, apply themes, and configure your system.${NC}"
echo -e "  ${MU}Requires: Ubuntu 24.04+, internet connection, sudo privileges.${NC}"
echo
read -p "  Press [Enter] to begin or Ctrl+C to abort... "
echo

# Check Sudo
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LOG_FILE="$SCRIPT_DIR/install.log"
: > "$LOG_FILE"

STEPS=(
    "0_privacy.sh|Privacy & Firewall"
    "1_dev_ai.sh|Developer & AI Stack"
    "2_ui.sh|Themes, Icons & Fonts"
    "3_shell.sh|Zsh + Starship Shell"
    "4_gnome.sh|GNOME Desktop Tuning"
    "5_branding.sh|Soadium Identity"
)
TOTAL=${#STEPS[@]}
FAILED=0

echo -e "  ${MU}Log: $LOG_FILE${NC}"
echo

run_step() {
    local n=$1 script=$2 label=$3
    local start=$SECONDS
    echo -ne "  ${IR}[${n}/${TOTAL}]${NC} ${TX}${label}${NC} ${MU}...${NC}"
    chmod +x "$SCRIPT_DIR/scripts/$script"
    if "$SCRIPT_DIR/scripts/$script" >> "$LOG_FILE" 2>&1; then
        echo -e "\r  ${IR}[${n}/${TOTAL}]${NC} ${TX}${label}${NC} ${GR}✔${NC} ${MU}$((SECONDS - start))s${NC}      "
    else
        echo -e "\r  ${IR}[${n}/${TOTAL}]${NC} ${TX}${label}${NC} ${RD}✘ failed${NC}"
        FAILED=1
        echo -e "  ${MU}See $LOG_FILE for details.${NC}"
        read -p "  Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

i=1
for entry in "${STEPS[@]}"; do
    run_step "$i" "${entry%%|*}" "${entry##*|}"
    i=$((i + 1))
done

echo
if [ "$FAILED" -eq 0 ]; then
    echo -e "  ${CY}────────────────────────────────────────────${NC}"
    echo -e "  ${FL}⬢${NC}  ${BD}${TX}Soadium OS is ready.${NC}"
    echo -e "  ${CY}────────────────────────────────────────────${NC}"
else
    echo -e "  ${FL}⬢${NC}  ${TX}Finished with warnings - check $LOG_FILE${NC}"
fi
echo
echo -e "  ${MU}Next:${NC} ${TX}reboot, open a terminal, run${NC} ${FL}soadium-fetch${NC}"
echo
read -p "  Reboot now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo reboot
fi
