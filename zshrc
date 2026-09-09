export PATH="${HOME}/.local/bin:${PATH}"

# devpod's ssh-server --stdio doesn't propagate $TERM. tmux refuses to start without
# it ("open terminal failed: terminal does not support clear"), and the failed exec
# becomes the SSH session's exit status, breaking `devpod up`'s tunnel.
export TERM="${TERM:-xterm-256color}"

# Auto-attach tmux on SSH login (real sshd sets $SSH_CONNECTION; devpod's
# ssh-server --stdio doesn't, so also check the parent process name)
if [ -z "$TMUX" ] && [ -t 1 ] && command -v tmux >/dev/null; then
  parent_cmd=$(tr '\0' ' ' < /proc/$PPID/cmdline 2>/dev/null)
  case "${parent_cmd:-}|$SSH_CONNECTION" in
    *sshd*|*ssh-server*|*SSH_CONNECTION=*)
      exec tmux new-session -A -s main
      ;;
  esac
fi
command -v starship >/dev/null && eval "$(starship init zsh)"

command -v zoxide   >/dev/null && eval "$(zoxide init zsh)"

command -v atuin    >/dev/null && eval "$(atuin init zsh)"

command -v direnv   >/dev/null && eval "$(direnv hook zsh)"

export BUN_INSTALL="$HOME/.bun"; export PATH="$BUN_INSTALL/bin:$PATH"

[ -f /usr/share/fzf/shell/key-bindings.zsh ] && source /usr/share/fzf/shell/key-bindings.zsh

[ -f /usr/share/fzf/shell/completion.zsh ]   && source /usr/share/fzf/shell/completion.zsh

[ -f ~/.bashrc.d/dp.sh ] && source ~/.bashrc.d/dp.sh

alias chrome='google-chrome --disable-features=ExtensionManifestV2Unsupported,ExtensionManifestV2Disabled'


# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/maxoliver/.lmstudio/bin"
# End of LM Studio CLI section



# Added by Antigravity CLI installer
export PATH="/home/maxoliver/.local/bin:$PATH"
