export EDITOR="vim"
export VISUAL="vim"

DOTFILES_DIR_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/dotfiles-dir"

if [[ -f $DOTFILES_DIR_CONFIG_FILE ]]; then
  read -r CONFIGURED_DOTFILES_DIR < "$DOTFILES_DIR_CONFIG_FILE"
fi

export DOTFILES_DIR="${CONFIGURED_DOTFILES_DIR:-$HOME/src/github.com/p-chan/dotfiles}"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$DOTFILES_DIR/bin:$PATH"

if type mise &>/dev/null; then
  eval "$(mise env -s zsh)"
fi

if [[ -f "${ZDOTDIR:-$HOME}/.zshenv.local" ]]; then
  source "${ZDOTDIR:-$HOME}/.zshenv.local"
fi
