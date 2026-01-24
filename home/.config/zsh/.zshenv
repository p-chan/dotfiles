export EDITOR="vim"
export VISUAL="vim"

DOTFILES_DIR_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/dotfiles-dir"

if [[ -f $DOTFILES_DIR_CONFIG_FILE ]]; then
  read -r CONFIGURED_DOTFILES_DIR < "$DOTFILES_DIR_CONFIG_FILE"
fi

export DOTFILES_DIR="${CONFIGURED_DOTFILES_DIR:-$HOME/src/github.com/p-chan/dotfiles}"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$DOTFILES_DIR/bin:$PATH"

# QMK dependencies (keg-only formulae from Homebrew)
# arm-none-eabi-gcc@8, arm-none-eabi-binutils, and avr-gcc@8 are not symlinked to PATH by default
# TODO: Can be removed when https://github.com/qmk/homebrew-qmk/issues/98 is resolved
if type brew &>/dev/null; then
  BREW_PREFIX="$(brew --prefix)"
  export PATH="$BREW_PREFIX/opt/arm-none-eabi-gcc@8/bin:$PATH"
  export PATH="$BREW_PREFIX/opt/arm-none-eabi-binutils/bin:$PATH"
  export PATH="$BREW_PREFIX/opt/avr-gcc@8/bin:$PATH"
fi

if type mise &>/dev/null; then
  eval "$(mise env -s zsh)"
fi

if [[ -f "${ZDOTDIR:-$HOME}/.zshenv.local" ]]; then
  source "${ZDOTDIR:-$HOME}/.zshenv.local"
fi
