export EDITOR="vim"
export VISUAL="vim"

typeset -U path fpath

# ~/.zshenv is a symlink into <repo>/home, managed by mise's dotfiles
# feature from the dotfiles.root setting. Resolving it locates the repo
# without forking a process on every shell startup (:A resolves symlinks in
# pure zsh). The fallback covers shells before the first install completes.
if [[ -L "$HOME/.zshenv" ]]; then
  export DOTFILES_DIR="${${:-$HOME/.zshenv}:A:h:h}"
else
  export DOTFILES_DIR="$HOME/src/github.com/p-chan/dotfiles"
fi
export PATH="$HOME/.local/bin:$PATH"
# Let interactive activation retain shims behind real tools as an update-safe fallback.
export PATH="$HOME/.local/share/mise/shims:$PATH"
export PATH="$DOTFILES_DIR/bin:$PATH"

# Claude Code searches with `rg -uuu`, which would otherwise read .env secrets
if [[ -n "$CLAUDECODE" ]]; then
  rg() { command rg --ignore-file="$DOTFILES_DIR/home/.claude/rgignore" "$@"; }
fi

# Interactive shells use `mise activate` from .zshrc; scripts need the
# environment immediately and stable shims across `mise up`.
if [[ ! -o interactive ]] && type mise &>/dev/null; then
  eval "$(mise env -s zsh)"
  path=("$HOME/.local/share/mise/shims" "${path[@]}")
fi

if [[ -f "${ZDOTDIR:-$HOME}/.zshenv.local" ]]; then
  source "${ZDOTDIR:-$HOME}/.zshenv.local"
fi

path=("${path[@]}")
