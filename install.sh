#!/usr/bin/env bash

set -euo pipefail

export DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export PATH="$DOTFILES/bin:$PATH"

echo "==> Configuring git"
read -rp "  Git user name: " GIT_USER_NAME
read -rp "  Git user email: " GIT_USER_EMAIL


echo "==> Linking files"
"$DOTFILES/install/link.sh"

echo "==> Setting up services"
"$DOTFILES/install/setup-services.sh"

echo "==> Installing global npm packages"
xargs -a "$DOTFILES/system/packages/npm.txt" sudo npm install -g


echo "==> Installing fonts"
mkdir -p ~/.local/share/fonts
unzip -o "$DOTFILES/system/fonts/fonts.zip" -d ~/.local/share/fonts/
fc-cache -f

echo "==> Configuring services"
"$DOTFILES/install/config/init.sh"
