#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Load pinned stable versions
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../versions.env"

echo -e "${GREEN}[+] Setting up Privacy & Security...${NC}"

# 1. Disable Telemetry & Error Reporting
echo "Disabling Apport (Error Reporting)..."
sudo systemctl stop apport.service || true
sudo systemctl disable apport.service || true
sudo sed -i 's/enabled=1/enabled=0/g' /etc/default/apport || true

echo "Removing ubuntu-report..."
sudo apt-get remove -y ubuntu-report || true

# 2. Setup Firewall (UFW)
echo "Setting up UFW Firewall..."
sudo apt-get install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
# Allow SSH if needed, otherwise keep it locked down
# sudo ufw allow ssh 
echo "Enabling UFW..."
sudo ufw --force enable

# 3. Install Privacy Browser (Brave, official stable channel)
echo "Installing Brave Browser (stable channel)..."
sudo apt-get install -y curl

sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ $BRAVE_APT_CHANNEL main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

sudo apt-get update
sudo apt-get install -y brave-browser

echo -e "${GREEN}[+] Privacy Setup Complete!${NC}"
