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
  # Set PATH and mise-managed env vars
  eval "$(mise env -s zsh)"
  # Prepend shims to PATH so commands resolve correctly after `mise up`
  eval "$(mise activate zsh --shims)"
fi

if [[ -f "${ZDOTDIR:-$HOME}/.zshenv.local" ]]; then
  source "${ZDOTDIR:-$HOME}/.zshenv.local"
fi
