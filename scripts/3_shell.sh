#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}[+] Setting up Shell (Zsh + Starship, stable releases)...${NC}"

# 1. Install Zsh (Ubuntu LTS stable package)
echo "Installing Zsh..."
sudo apt-get install -y zsh

# 2. Install Starship (official installer, latest stable release)
echo "Installing Starship Prompt..."
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# 3. Install Oh My Zsh (unattended; master is its stable release channel)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 4. Zsh plugins (shallow clones of the maintained stable branches)
echo "Installing Zsh Plugins..."
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# 5. Configure .zshrc
echo "Configuring .zshrc..."
cat <<EOF > "$HOME/.zshrc"
export ZSH="\$HOME/.oh-my-zsh"

ZSH_THEME="" # Disable OMZ theme to use Starship
plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker python npm)

source \$ZSH/oh-my-zsh.sh

# Starship init
eval "\$(starship init zsh)"

# nvm (Node.js LTS)
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"

# pipx-installed CLI tools
export PATH="\$HOME/.local/bin:\$PATH"

# thefuck (command correction), if installed
command -v thefuck > /dev/null && eval "\$(thefuck --alias)"

# Aliases
alias ll='ls -alF'
alias cls='clear'
alias update='sudo apt update && sudo apt upgrade -y'

# Editors
export EDITOR='code'
EOF

echo "Changing default shell to zsh..."
chsh -s "$(which zsh)" || true

echo -e "${GREEN}[+] Shell Setup Complete! Please log out and back in.${NC}"
