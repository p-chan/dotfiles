autoload -Uz compinit
_zcompdump="${ZDOTDIR:-$HOME}/.zcompdump"
# Recheck completion files and permissions daily; trust the dump between checks.
if [[ -s "$_zcompdump" && -n "$_zcompdump"(#qN.mh-24) ]]; then
  compinit -C -d "$_zcompdump"
else
  compinit -d "$_zcompdump" && command touch "$_zcompdump"
fi
unset _zcompdump

bindkey -v

# Backward word (Shift + Arrow Left)
bindkey '^[[1;2D' backward-word
# Forward word (Shift + Arrow Right)
bindkey '^[[1;2C' forward-word

if type starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

if type mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

if type sheldon &>/dev/null; then
  eval "$(sheldon source)"
fi

if type fzf &>/dev/null; then
  source <(fzf --zsh)
fi

if type zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

if type git-wt &>/dev/null; then
  eval "$(git wt --init zsh)"
fi

# git switch/sw → git-fallback-switch; composes with git-wt wrapper if present
if typeset -f git > /dev/null 2>&1; then
  functions[_git_before_switch]=${functions[git]}
  unfunction git
  git() {
    case "${1-}" in
      switch|sw) shift; command git-fallback-switch "$@" ;;
      *) _git_before_switch "$@" ;;
    esac
  }
else
  git() {
    case "${1-}" in
      switch|sw) shift; command git-fallback-switch "$@" ;;
      *) command git "$@" ;;
    esac
  }
fi

_fzf_colors=(
  --color=fg:#abb2bf,fg+:#ffffff,bg:#282c34,bg+:#3e4452
  --color=hl:#61afef,hl+:#61afef,info:#abb2bf,marker:#61afef
  --color=prompt:#61afef,spinner:#61afef,pointer:#528bff,header:#abb2bf
  --color=border:#5c6370,label:#abb2bf,query:#ffffff
)

export FZF_DEFAULT_OPTS="--layout=reverse ${_fzf_colors[*]}"

# fzf-tab ignores FZF_DEFAULT_OPTS by default; pass colors explicitly
zstyle ':fzf-tab:*' fzf-flags $_fzf_colors

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

# PR ごとに worktree を作成して移動する（fork からの PR は非対応）
# convention.use-worktree=false のリポジトリでは gh pr checkout にフォールバックする
function _gh_pr_fuzzy_worktree() {
  selected=$(
    GH_FORCE_TTY=100% \
    gh pr list --limit 100 \
    --json number,title,headRefName,isDraft \
    --template '{{range .}}{{ $color := "green" }}{{if .isDraft}}{{ $color = "black+h" }}{{end}}{{tablerow (color $color (printf "#%.0f" .number)) .title (color "cyan" .headRefName)}}{{end}}{{tablerender}}' \
    | fzf --ansi
  )

  if [[ -n "$selected" ]]; then
    number=$(echo "$selected" | awk '{print $1}' | sed 's/^#//')
    if [[ "$(git config --local --get convention.use-worktree 2>/dev/null)" == "false" ]]; then
      BUFFER="gh pr checkout $number"
    else
      # 表示上の headRefName は truncate されうるので、API から正確な値を取得する
      branch=$(gh pr view "$number" --json headRefName -q .headRefName)
      BUFFER="git fetch origin && git wt ${(q)branch}"
    fi
    zle accept-line
  fi
}

zle -N _gh_pr_fuzzy_worktree
bindkey "^P" _gh_pr_fuzzy_worktree

# 現在のリポジトリの worktree 一覧から選んで移動する
function _git_worktree_fuzzy_cd() {
  local worktrees=$(command git worktree list --porcelain 2>/dev/null)
  if [[ -z "$worktrees" ]]; then
    zle -M "Not a git repository"
    return
  fi

  local cwd=$(command git rev-parse --show-toplevel)

  local selected=$(
    print -r -- "$worktrees" | awk -v cwd="$cwd" '
      function flush() {
        if (path == "") return
        n++
        paths[n] = path
        # detached HEAD の worktree には branch 行がない
        refs[n] = (ref == "" ? "(detached)" : ref)
        marks[n] = (path == cwd ? "*" : " ")
        if (length(refs[n]) > width) width = length(refs[n])
        path = ""; ref = ""
      }
      /^worktree / { flush(); path = substr($0, 10) }
      /^branch /   { ref = substr($0, 8); sub(/^refs\/heads\//, "", ref) }
      END {
        flush()
        for (i = 1; i <= n; i++)
          printf "%s \033[32m%-*s\033[0m\t%s\n", marks[i], width, refs[i], paths[i]
      }
    ' | fzf --ansi --delimiter=$'\t' --with-nth=1 --preview '
      echo {2}
      echo
      git -C {2} -c color.ui=always status --short --branch
      echo
      git -C {2} log --oneline --decorate --color=always -20
    '
  )

  if [[ -n "$selected" ]]; then
    BUFFER="cd ${(q)${selected##*$'\t'}}"
    zle accept-line
  fi
}

zle -N _git_worktree_fuzzy_cd
bindkey "^W" _git_worktree_fuzzy_cd

function _ghq_fuzzy_cd() {
  local root=$(ghq root)
  local selected=$(ghq list | fzf --preview "
    dir=$root/{}
    readme=\$(find \"\$dir\" -maxdepth 1 -iname 'readme*' -type f 2>/dev/null | head -1)
    if [[ -z \"\$readme\" ]]; then
      echo 'No README'
    elif [[ \"\$readme\" == *.[Mm][Dd] || \"\$readme\" == *.[Mm]arkdown ]]; then
      mdroll --width \"\$FZF_PREVIEW_COLUMNS\" \"\$readme\"
    else
      # README.rst や拡張子なしの README は Markdown ではないので bat に任せる
      bat --style=plain --color=always \"\$readme\"
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

path=("${path[@]}")
