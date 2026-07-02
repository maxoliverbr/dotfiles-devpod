# .bashrc

# Skip when sourced from a non-bash shell (e.g. `source ~/.bashrc` in zsh).
[ -n "$BASH_VERSION" ] || return 0

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc
export PATH="$HOME/.local/bin:$PATH" # or /home/maxoliver/.zshrc

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/maxoliver/.lmstudio/bin"
# End of LM Studio CLI section

. "$HOME/.cargo/env"


# Added by Antigravity CLI installer
export PATH="/home/maxoliver/.local/bin:$PATH"

# dp function lives in ~/.bashrc.d/dp.sh (sourced via the loop below)
