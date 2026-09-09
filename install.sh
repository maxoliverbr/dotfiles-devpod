#!/usr/bin/env bash
set -e
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.bun/bin:$PATH"

mkdir -p ~/.bashrc.d ~/.local/bin

ln -sfn "$DOTFILES_DIR/bashrc"        ~/.bashrc
ln -sfn "$DOTFILES_DIR/zshrc"         ~/.zshrc
ln -sfn "$DOTFILES_DIR/bashrc.d/dp.sh" ~/.bashrc.d/dp.sh

sudo apt-get update -qq
sudo apt-get install -y -qq zsh zoxide direnv unzip tmux
sudo chsh -s "$(command -v zsh)" "$(whoami)"

curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin

curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh || true
if [ -f "$HOME/.cargo/bin/atuin" ]; then
    ln -sfn "$HOME/.cargo/bin/atuin" ~/.local/bin/atuin
fi

curl -fsSL https://bun.com/install | bash || true

curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path || true
if [ -f ~/.opencode/bin/opencode ]; then
    ln -sfn ~/.opencode/bin/opencode ~/.local/bin/opencode
fi

echo "dotfiles installed"
