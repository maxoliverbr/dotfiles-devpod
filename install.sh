#!/usr/bin/env bash
set -e
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p ~/.bashrc.d ~/.local/bin

ln -sfn "$DOTFILES_DIR/bashrc"         ~/.bashrc
ln -sfn "$DOTFILES_DIR/zshrc"          ~/.zshrc
ln -sfn "$DOTFILES_DIR/bashrc.d/dp.sh" ~/.bashrc.d/dp.sh

sudo apt-get update -qq
sudo apt-get install -y -qq zsh zoxide direnv unzip
sudo chsh -s "$(command -v zsh)" "$(whoami)"

# Not apt-installable, and their own installers would append to ~/.zshrc,
# ~/.bashrc — which are this repo's own files, so grab plain release
# binaries instead. To add a new tool: apt-get installable -> add to the
# line above. Otherwise -> same 3-line shape as below.

curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin

curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

curl -fsSL https://bun.com/install | bash

curl -fsSL https://opencode.ai/install | bash

echo "dotfiles installed"
