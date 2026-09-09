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

# Re-running the installers below on every boot cost ~8s of a ~13s `devpod up`,
# all of it redoing work already done. Skip whatever is already present.
# DOTFILES_FORCE_INSTALL=1 reinstalls everything, e.g. to pull tool upgrades.
have() { [ -z "${DOTFILES_FORCE_INSTALL:-}" ] && command -v "$1" >/dev/null 2>&1; }

# devpod configures the container's git identity with `su vscode -c 'git config
# --global ...'` from cwd=/root. /root is 0700, so git's repo discovery stats
# /root/.git, gets EACCES rather than ENOENT, and dies with exit 128 -- devpod
# retries ~20x per boot, all failing, and the container ends up with no identity.
# o+x grants traverse only (not read/list); git then gets ENOENT and proceeds.
# Runs early so devpod's remaining retries land inside this same boot.
# ponytail: workaround for loft-sh/devpod; drop it if upstream stops using cwd=/root.
sudo chmod o+x /root

ln -sfn "$DOTFILES_DIR/bashrc"        ~/.bashrc
ln -sfn "$DOTFILES_DIR/zshrc"         ~/.zshrc

# Only touch apt when something is actually missing; `update` + a no-op
# `install` were 2.5s of every boot. DEBIAN_FRONTEND because devpod runs this
# without a controlling tty, so debconf otherwise walks Dialog -> Readline ->
# Teletype -> Noninteractive, printing an "unable to initialize frontend" pair
# for each. >/dev/null drops dpkg chatter; stderr stays open so a real apt
# failure is still visible (set -e aborts).
missing=""
for pkg in zsh zoxide direnv unzip tmux; do
    dpkg -s "$pkg" >/dev/null 2>&1 || missing="$missing $pkg"
done
if [ -n "$missing" ]; then
    sudo apt-get update -qq
    sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq $missing >/dev/null
fi
[ "$(getent passwd "$(id -un)" | cut -d: -f7)" = "$(command -v zsh)" ] \
    || sudo chsh -s "$(command -v zsh)" "$(whoami)"

have starship || { curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b ~/.local/bin; } >/dev/null 2>&1

# --non-interactive: without it the installer probes /dev/tty, and the failed
# `exec 3</dev/tty` kills POSIX sh outright when devpod runs this without a tty.
have atuin || { curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh -s -- --non-interactive; } >/dev/null 2>&1 || true
if [ -x "$HOME/.atuin/bin/atuin" ]; then
    ln -sfn "$HOME/.atuin/bin/atuin" ~/.local/bin/atuin
fi

have bun || { curl -fsSL https://bun.com/install | bash; } >/dev/null 2>&1 || true

have opencode || { curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path; } >/dev/null 2>&1 || true
if [ -f ~/.opencode/bin/opencode ]; then
    ln -sfn ~/.opencode/bin/opencode ~/.local/bin/opencode
fi

# herdr: agent-aware terminal multiplexer. Its installer drops the binary in
# ~/.local/bin itself. dev-session builds the opencode + zsh tab layout and is
# what `devpod up` attaches to.
have herdr || { curl -fsSL https://herdr.dev/install.sh | sh; } >/dev/null 2>&1 || true
ln -sfn "$DOTFILES_DIR/bin/dev-session" ~/.local/bin/dev-session

# The installers above append to ~/.zshrc and ~/.bashrc, which are symlinks into
# this clone -- that is how host-machine PATH junk once got committed here, and
# atuin leaves an unguarded `. ~/.atuin/bin/env` that breaks login if it is ever
# missing. The rc files in git already init every tool defensively, so drop them.
git -C "$DOTFILES_DIR" checkout -- .

echo "dotfiles installed"
