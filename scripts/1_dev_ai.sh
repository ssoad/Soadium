#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

# Load pinned stable versions
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/../versions.env"

echo -e "${GREEN}[+] Setting up Developer Tools & AI (stable releases only)...${NC}"

# 1. Essentials & core developer CLI tools
echo "Installing essential packages..."
sudo apt-get update
sudo apt-get install -y \
    git curl wget ca-certificates gnupg \
    build-essential pkg-config make \
    software-properties-common \
    jq tmux htop tree unzip zip shellcheck

# 2. GitHub CLI (official stable apt repository)
echo "Installing GitHub CLI..."
if ! command -v gh &> /dev/null; then
    sudo install -d -m 0755 /usr/share/keyrings
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | sudo tee /usr/share/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y gh
fi

# 3. VS Code (snap, stable channel)
echo "Installing VS Code (stable channel)..."
if ! command -v code &> /dev/null; then
    sudo snap install code --classic --channel="$VSCODE_SNAP_CHANNEL"
fi

# 4. Docker Engine (official Docker CE stable channel, not the outdated docker.io)
echo "Installing Docker Engine (stable channel)..."
if ! command -v docker &> /dev/null; then
    sudo install -d -m 0755 /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") $DOCKER_APT_CHANNEL" \
        | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable --now docker || true
    sudo usermod -aG docker "$USER"
fi

# 5. Python (Ubuntu LTS stable packages) + pipx for isolated CLI tools
echo "Installing Python toolchain..."
sudo apt-get install -y python3 python3-pip python3-venv python3-dev pipx
pipx ensurepath || true

# 6. Node.js LTS via nvm (pinned stable nvm release, Node LTS channel)
echo "Installing nvm $NVM_VERSION and Node.js LTS..."
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash
fi
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install "$NODE_CHANNEL"
nvm alias default 'lts/*'

# 7. AI Tools (Ollama, official stable release)
echo "Installing Ollama (Local AI Runtime)..."
if ! command -v ollama &> /dev/null; then
    curl -fsSL https://ollama.com/install.sh | sh
fi

# 8. Terminal QoL: thefuck (command correction) via pipx
#    (pip3 --user is blocked by PEP 668 on Ubuntu 24.04; pipx is the stable path)
echo "Installing 'thefuck' (command correction)..."
pipx install thefuck || true

echo -e "${GREEN}[+] Developer & AI Setup Complete!${NC}"
