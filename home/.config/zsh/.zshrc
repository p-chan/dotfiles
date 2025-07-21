autoload -Uz compinit
compinit

# Backward word (Shift + Arrow Left)
bindkey '^[[1;2D' backward-word
# Forward word (Shift + Arrow Right)
bindkey '^[[1;2C' forward-word

if type sheldon &>/dev/null; then
  eval "$(sheldon source)"
fi

if type starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

if type fzf &>/dev/null; then
  source <(fzf --zsh)
fi

HISTSIZE=100000
SAVEHIST=100000
setopt inc_append_history
setopt share_history
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks

# zsh-syntax-highlighting
# https://github.com/zsh-users/zsh-syntax-highlighting/tree/master/highlighters/main

typeset -A ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red'
ZSH_HIGHLIGHT_STYLES[alias]='fg=blue'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=blue'
ZSH_HIGHLIGHT_STYLES[function]='fg=blue'
ZSH_HIGHLIGHT_STYLES[command]='fg=blue'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=blue'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=green'
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan,underline'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=blue'
ZSH_HIGHLIGHT_STYLES[default]='fg=cyan'

function reload() {
  source "${ZDOTDIR:-$HOME}/.zshenv"
  source "${ZDOTDIR:-$HOME}/.zprofile"
  source "${ZDOTDIR:-$HOME}/.zshrc"
}

if [[ -f "${ZDOTDIR:-$HOME}/.zshrc.local" ]]; then
  source "${ZDOTDIR:-$HOME}/.zshrc.local"
fi
