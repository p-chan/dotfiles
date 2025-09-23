export ZDOTDIR="$HOME/.config/zsh"

export EDITOR="vim"
export VISUAL="vim"

export DOTFILES_DIR="${DOTFILES_DIR:-$HOME/src/github.com/p-chan/dotfiles}"
export PATH="$DOTFILES_DIR/bin:$PATH"

if type mise &>/dev/null; then
  eval "$(mise env -s zsh)"
fi

if [[ -f "$HOME/.zshenv.local" ]]; then
  source "$HOME/.zshenv.local"
fi
