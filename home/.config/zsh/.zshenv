export EDITOR="vim"
export VISUAL="vim"

export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/src/github.com/p-chan/dotfiles}"
export PATH="$DOTFILES_DIR/bin:$PATH"

if [ -x /opt/homebrew/bin/brew ]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi

if type mise &>/dev/null; then
  eval "$(mise activate zsh --shims)"
fi

if [[ -f "${ZDOTDIR:-$HOME}/.zshenv.local" ]]; then
  source "${ZDOTDIR:-$HOME}/.zshenv.local"
fi
