export EDITOR="vim"
export VISUAL="vim"

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
export PATH="$HOME/.local/share/mise/shims:$PATH"
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
