#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}[+] Setting up Developer Tools & AI...${NC}"

# 1. Essentials
echo "Installing essential packages..."
sudo apt-get update
sudo apt-get install -y git curl wget build-essential software-properties-common

# 2. Install VS Code
echo "Installing VS Code..."
if ! command -v code &> /dev/null; then
    sudo snap install code --classic
fi

# 3. Install Docker
echo "Installing Docker..."
if ! command -v docker &> /dev/null; then
    sudo apt-get install -y docker.io
    sudo usermod -aG docker $USER
    # Activate group changes without logout (for this script execution context)
    newgrp docker < /dev/null || true
fi

# 4. Install Python & Node.js
echo "Installing Python and Node.js..."
sudo apt-get install -y python3 python3-pip python3-venv

# Install NVM & Node
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
fi

# 5. Install AI Tools (Ollama)
echo "Installing Ollama (Local AI Runtime)..."
if ! command -v ollama &> /dev/null; then
    curl -fsSL https://ollama.com/install.sh | sh
fi

# 6. Terminal AI (Shell Genie or similar, let's use a placeholder or a simple pip tool)
# Using 'fuck' as a simple example of correction, or suggest a CLI AI tool
echo "Installing 'thefuck' (Command correction)..."
sudo apt-get install -y python3-dev python3-pip python3-setuptools
pip3 install thefuck --user || true

echo -e "${GREEN}[+] Developer & AI Setup Complete!${NC}"
