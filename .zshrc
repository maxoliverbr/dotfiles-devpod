export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.bun/bin:$PATH"

if (( $+commands[starship] )); then
    eval "$(starship init zsh)"
fi

if (( $+commands[atuin] )); then
    eval "$(atuin init zsh)"
fi

if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi

if (( $+commands[direnv] )); then
    eval "$(direnv hook zsh)"
fi
