export PATH="${HOME}/.local/bin:${PATH}"
eval "$(starship init zsh)"

eval "$(zoxide init zsh)"

eval "$(atuin init zsh)"

eval "$(direnv hook zsh)"

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
