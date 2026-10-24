#
# ~/.bashrc
#

# Stop here if the shell is not interactive
[[ $- != *i* ]] && return


# ─── PATH ────────────────────────────────────────────────────────────────────

# pipx and other user-installed binaries
export PATH="$PATH:$HOME/.local/bin"

# LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Homebrew (Linuxbrew)
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
fi


# ─── History ─────────────────────────────────────────────────────────────────

HISTSIZE=10000
HISTFILESIZE=10000
HISTFILE=~/.bash_history
HISTCONTROL=ignoreboth      # skip duplicates and commands starting with a space
shopt -s histappend         # append to the history file instead of overwriting


# ─── Completion ──────────────────────────────────────────────────────────────

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi


# ─── Prompt & tools ──────────────────────────────────────────────────────────

# Oh My Posh prompt
if command -v oh-my-posh >/dev/null 2>&1; then
    eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/config.omp.json)"
fi

# zoxide (smarter cd command)
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi


# ─── Aliases ─────────────────────────────────────────────────────────────────

# bat as a drop-in replacement for cat
if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
fi

# Optional
# alias cd='z'
# alias update='sudo pacman -Syyu'


# ─── Greeting ────────────────────────────────────────────────────────────────

if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi
