#!/usr/bin/env bash
set -euo pipefail
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log() { printf '[dotfiles] %s\n' "$*" >&2; }

mkdir -p "$HOME/.bashrc.d"

link() {
  local src="$1" dst="$2"
  [[ -e "$dst" && ! -L "$dst" ]] && mv "$dst" "$dst.bak.$(date +%s)"
  ln -sfn "$src" "$dst"
}

link "$DOTFILES_DIR/bashrc"          "$HOME/.bashrc"
link "$DOTFILES_DIR/zshrc"           "$HOME/.zshrc"
link "$DOTFILES_DIR/bashrc.d/dp.sh"  "$HOME/.bashrc.d/dp.sh"

log "core dotfiles symlinked from $DOTFILES_DIR"

SUDO=""
if [[ "$(id -u)" -eq 0 ]]; then
  SUDO=""
elif command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
  SUDO="sudo"
else
  log "no root / no passwordless sudo — skipping privileged steps (apt, chsh)"
fi

set +e

if ! command -v zsh >/dev/null 2>&1; then
  if [[ -n "$SUDO" ]] && command -v apt-get >/dev/null 2>&1; then
    log "installing zsh via apt-get"
    $SUDO apt-get update -qq && $SUDO apt-get install -y -qq zsh
  fi
fi
if command -v zsh >/dev/null 2>&1 && [[ -n "$SUDO" ]]; then
  log "chsh to zsh for $(whoami)"
  $SUDO chsh -s "$(command -v zsh)" "$(whoami)" || log "chsh failed, continuing"
else
  log "zsh unavailable or no sudo — skipping chsh"
fi

if [[ -n "$SUDO" ]] && command -v apt-get >/dev/null 2>&1; then
  log "installing zoxide, direnv via apt-get"
  $SUDO apt-get update -qq
  $SUDO apt-get install -y -qq zoxide direnv || log "apt install of zoxide/direnv failed, continuing"
else
  log "apt-get/sudo unavailable — skipping zoxide/direnv"
fi

mkdir -p "$HOME/.local/bin"

if ! command -v starship >/dev/null 2>&1; then
  log "installing starship to ~/.local/bin"
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin" \
    || log "starship install failed, continuing"
fi

if ! command -v atuin >/dev/null 2>&1; then
  arch="$(uname -m)"
  if [[ "$arch" == "x86_64" ]]; then
    log "installing atuin (x86_64 release binary)"
    tmpd="$(mktemp -d)"
    if curl -fsSL "https://github.com/atuinsh/atuin/releases/latest/download/atuin-x86_64-unknown-linux-gnu.tar.gz" \
         | tar xz -C "$tmpd" 2>/dev/null; then
      mv "$tmpd/atuin-x86_64-unknown-linux-gnu/atuin" "$HOME/.local/bin/atuin" \
        || log "atuin binary move failed"
    else
      log "atuin download/extract failed, continuing"
    fi
    rm -rf "$tmpd"
  else
    log "unsupported arch ($arch) for atuin release binary — skipping"
  fi
fi

if ! command -v bun >/dev/null 2>&1; then
  arch="$(uname -m)"
  case "$arch" in
    x86_64)  bun_target="bun-linux-x64" ;;
    aarch64) bun_target="bun-linux-aarch64" ;;
    *)       bun_target="" ;;
  esac
  if [[ -n "$bun_target" ]]; then
    log "installing bun ($bun_target release binary)"
    tmpd="$(mktemp -d)"
    if curl -fsSL "https://github.com/oven-sh/bun/releases/latest/download/${bun_target}.zip" -o "$tmpd/bun.zip" \
         && (command -v unzip >/dev/null 2>&1 || { [[ -n "$SUDO" ]] && command -v apt-get >/dev/null 2>&1 && $SUDO apt-get install -y -qq unzip; }) \
         && unzip -q "$tmpd/bun.zip" -d "$tmpd"; then
      mkdir -p "$HOME/.bun/bin"
      mv "$tmpd/${bun_target}/bun" "$HOME/.bun/bin/bun" || log "bun binary move failed"
    else
      log "bun download/extract failed, continuing"
    fi
    rm -rf "$tmpd"
  else
    log "unsupported arch ($arch) for bun release binary — skipping"
  fi
fi

log "provisioning complete"
