#!/usr/bin/env bash
set -euo pipefail
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$HOME/.bashrc.d"

link() {
  local src="$1" dst="$2"
  [[ -e "$dst" && ! -L "$dst" ]] && mv "$dst" "$dst.bak.$(date +%s)"
  ln -sfn "$src" "$dst"
}

link "$DOTFILES_DIR/bashrc"          "$HOME/.bashrc"
link "$DOTFILES_DIR/zshrc"           "$HOME/.zshrc"
link "$DOTFILES_DIR/bashrc.d/dp.sh"  "$HOME/.bashrc.d/dp.sh"

echo "Dotfiles installed from $DOTFILES_DIR"
