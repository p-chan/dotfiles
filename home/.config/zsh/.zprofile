export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/src/github.com/p-chan/dotfiles}"

if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if type mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

if [[ -f "${ZDOTDIR:-$HOME}/.zprofile.local" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile.local"
fi
