#!/usr/bin/env bash
set -e
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Sync local clone with origin so changes pushed between devpod up runs actually land.
# Tool installers (bun, opencode, lm-studio) append to ~/.zshrc, which is a symlink
# back into this clone, so discard those mutations before resetting.
# The reset rewrites THIS script under the running bash, which reads by byte offset,
# so re-exec the freshly synced copy instead of finishing on a half-stale one.
if [ "${1:-}" != "--synced" ]; then
    git -C "$DOTFILES_DIR" checkout -- . 2>/dev/null || true
    git -C "$DOTFILES_DIR" fetch --quiet origin main
    git -C "$DOTFILES_DIR" reset --hard origin/main
    exec bash "$DOTFILES_DIR/install.sh" --synced
fi

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.bun/bin:$PATH"

mkdir -p ~/.bashrc.d ~/.local/bin

ln -sfn "$DOTFILES_DIR/bashrc"        ~/.bashrc
ln -sfn "$DOTFILES_DIR/zshrc"         ~/.zshrc
ln -sfn "$DOTFILES_DIR/bashrc.d/dp.sh" ~/.bashrc.d/dp.sh

sudo apt-get update -qq
sudo apt-get install -y -qq zsh zoxide direnv unzip tmux
sudo chsh -s "$(command -v zsh)" "$(whoami)"

{ curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin; } >/dev/null 2>&1

# --non-interactive: without it the installer probes /dev/tty, and the failed
# `exec 3</dev/tty` kills POSIX sh outright when devpod runs this without a tty.
{ curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh -s -- --non-interactive; } >/dev/null 2>&1 || true
if [ -x "$HOME/.atuin/bin/atuin" ]; then
    ln -sfn "$HOME/.atuin/bin/atuin" ~/.local/bin/atuin
fi

{ curl -fsSL https://bun.com/install | bash; } >/dev/null 2>&1 || true

{ curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path; } >/dev/null 2>&1 || true
if [ -f ~/.opencode/bin/opencode ]; then
    ln -sfn ~/.opencode/bin/opencode ~/.local/bin/opencode
fi

# The installers above append to ~/.zshrc and ~/.bashrc, which are symlinks into
# this clone -- that is how host-machine PATH junk once got committed here, and
# atuin leaves an unguarded `. ~/.atuin/bin/env` that breaks login if it is ever
# missing. The rc files in git already init every tool defensively, so drop them.
git -C "$DOTFILES_DIR" checkout -- .

echo "dotfiles installed"
