export EDITOR="vim"
export VISUAL="vim"

# Already
: "${DOTFILES_DIR:=${DOTFILES_DIR}}"
# GitHub Actions
: "${DOTFILES_DIR:=${GITHUB_WORKSPACE:-}}"
# GitHub Codespaces
: "${DOTFILES_DIR:=${CODESPACES:+/workspaces/.codespaces/.persistedshare/dotfiles}}"
# Default
: "${DOTFILES_DIR:=$HOME/src/github.com/p-chan/dotfiles}"

export DOTFILES_DIR
export PATH="$DOTFILES_DIR/bin:$PATH"

if type mise &>/dev/null; then
  eval "$(mise env -s zsh)"
fi

if [[ -f "$HOME/.zshenv.local" ]]; then
  source "$HOME/.zshenv.local"
fi
