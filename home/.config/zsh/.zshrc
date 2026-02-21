autoload -Uz compinit
compinit

bindkey -v

# Backward word (Shift + Arrow Left)
bindkey '^[[1;2D' backward-word
# Forward word (Shift + Arrow Right)
bindkey '^[[1;2C' forward-word

if type mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

if type sheldon &>/dev/null; then
  eval "$(sheldon source)"
fi

if type starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

if type fzf &>/dev/null; then
  source <(fzf --zsh)
fi

if type zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

export FZF_DEFAULT_OPTS="
  --layout=reverse
  --color=fg:#abb2bf,fg+:#ffffff,bg:#282c34,bg+:#3e4452
  --color=hl:#61afef,hl+:#61afef,info:#abb2bf,marker:#61afef
  --color=prompt:#61afef,spinner:#61afef,pointer:#528bff,header:#abb2bf
  --color=border:#5c6370,label:#abb2bf,query:#ffffff
"

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

function _gh_pr_fuzzy_checkout() {
  number=$(
    GH_FORCE_TTY=100% \
    gh pr list --limit 100 \
    --json number,title,headRefName,isDraft \
    --template '{{range .}}{{ $color := "green" }}{{if .isDraft}}{{ $color = "black+h" }}{{end}}{{tablerow (color $color (printf "#%.0f" .number)) .title (color "cyan" .headRefName)}}{{end}}{{tablerender}}' \
    | fzf --ansi \
    | awk '{print $1}' \
    | sed 's/^#//'
  )

  if [[ -n "$number" ]]; then
    BUFFER="gh pr checkout $number"
    zle accept-line
  fi
}

zle -N _gh_pr_fuzzy_checkout
bindkey "^P" _gh_pr_fuzzy_checkout

function _ghq_fuzzy_cd() {
  local root=$(ghq root)
  local selected=$(ghq list | fzf --preview "
    dir=$root/{}
    readme=\$(find \"\$dir\" -maxdepth 1 -iname 'readme*' -type f 2>/dev/null | head -1)
    if [[ -n \"\$readme\" ]]; then
      bat --style=plain --color=always \"\$readme\"
    else
      echo 'No README'
    fi
  ")
  if [[ -n "$selected" ]]; then
    BUFFER="cd $root/$selected"
    zle accept-line
  fi
}

zle -N _ghq_fuzzy_cd
bindkey "^G" _ghq_fuzzy_cd

if [[ -f "${ZDOTDIR:-$HOME}/.zshrc.local" ]]; then
  source "${ZDOTDIR:-$HOME}/.zshrc.local"
fi

# Git wrapper
git() {
  case "${1-}" in
    switch)
      shift
      command git-fallback-switch "$@"
      ;;
    *)
      command git "$@"
      ;;
  esac
}
