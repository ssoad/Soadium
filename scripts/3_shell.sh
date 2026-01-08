#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}[+] Setting up Shell (Zsh + Starship)...${NC}"

# 1. Install Zsh
echo "Installing Zsh..."
sudo apt-get install -y zsh

# 2. Install Starship
echo "Installing Starship Prompt..."
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# 3. Install Zsh Plugins
echo "Installing Zsh Plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
# We aren't installing Oh My Zsh explicitly to keep it lighter, but using a similar structure for plugins if the user wants OMZ later, or we can use a simple plugin manager.
# Let's use a manual plugin setup for simplicity and speed without the OMZ bulk, or just install OMZ non-interactively.
# Standard Approach: Install Oh My Zsh properly
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
# Autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
# Syntax Highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# 4. Configure .zshrc
echo "Configuring .zshrc..."
cat <<EOF > "$HOME/.zshrc"
export ZSH="\$HOME/.oh-my-zsh"

ZSH_THEME="" # Disable OMZ theme to use Starship
plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker python npm)

source \$ZSH/oh-my-zsh.sh

# Starship init
eval "\$(starship init zsh)"

# Aliases
alias ll='ls -alF'
alias cls='clear'
alias update='sudo apt update && sudo apt upgrade -y'

# Editors
export EDITOR='code'
EOF

echo "Changing default shell to zsh..."
chsh -s $(which zsh) || true

echo -e "${GREEN}[+] Shell Setup Complete! Please log out and back in.${NC}"
