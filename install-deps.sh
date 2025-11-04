#!/bin/bash
# ===============================================================
# Debian 13 - Base Development Environment Setup Script
# Installs core packages, configures SSH, and basic dev tools
# ===============================================================

set -e

# Colors for output
GREEN="\e[32m"
YELLOW="\e[33m"
RESET="\e[0m"

echo -e "${GREEN}[*] Updating system packages...${RESET}"
sudo apt update -y && sudo apt upgrade -y

echo -e "${GREEN}[*] Installing core developer utilities...${RESET}"
sudo apt install -y \
    git \
    openssh-client \
    openssh-server \
    vim \
    tree \
    htop \
    curl \
    wget \
    net-tools \
    lsof \
    jq \
    tmux \
    ca-certificates \
    unzip \
    build-essential \
    software-properties-common \
    apt-transport-https \
    gnupg \
    bash-completion

echo -e "${GREEN}[*] Enabling and starting SSH service...${RESET}"
sudo systemctl enable ssh
sudo systemctl start ssh

# Generate SSH key pair for GitHub if none exists
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo -e "${YELLOW}[?] Generating SSH key for GitHub...${RESET}"
    read -p "Enter email for SSH key (or leave blank): " email
    if [ -z "$email" ]; then
        ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N ""
    else
        ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519" -N ""
    fi
    eval "$(ssh-agent -s)"
    ssh-add "$HOME/.ssh/id_ed25519"
    echo -e "${GREEN}[*] SSH key generated successfully.${RESET}"
    echo -e "${YELLOW}--- Copy this public key to GitHub ---${RESET}"
    echo
    cat "$HOME/.ssh/id_ed25519.pub"
    echo
    echo -e "${YELLOW}--------------------------------------${RESET}"
else
    echo -e "${YELLOW}[!] SSH key already exists. Skipping generation.${RESET}"
fi

# Create SSH config for GitHub if not present
SSH_CONFIG="$HOME/.ssh/config"
if ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
    echo -e "${GREEN}[*] Adding GitHub config to ~/.ssh/config...${RESET}"
    mkdir -p "$HOME/.ssh"
    cat >> "$SSH_CONFIG" <<'EOF'

Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519
  IdentitiesOnly yes
EOF
    chmod 600 "$SSH_CONFIG"
fi

# Configure Git defaults
echo -e "${GREEN}[*] Configuring global Git settings...${RESET}"
git config --global init.defaultBranch main
read -p "Enter your Git username: " gitname
git config --global user.name "$gitname"
read -p "Enter your Git email: " gitemail
git config --global user.email "$gitemail"
git config --global color.ui auto

echo -e "${GREEN}[*] Setup complete!${RESET}"
echo -e "${YELLOW}Remember to add your SSH key to GitHub for cloning repos.${RESET}"
echo -e "${YELLOW}Run 'cat ~/.ssh/id_ed25519.pub' to view your public key.${RESET}"
