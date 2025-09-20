export EDITOR="vim"
export VISUAL="vim"

export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/src/github.com/p-chan/dotfiles}"
export PATH="$DOTFILES_DIR/bin:$PATH"

if type mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

if [[ -f "${ZDOTDIR:-$HOME}/.zshenv.local" ]]; then
  source "${ZDOTDIR:-$HOME}/.zshenv.local"
fi
