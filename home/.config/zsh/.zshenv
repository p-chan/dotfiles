export EDITOR="vim"
export VISUAL="vim"

eval "$(mise activate zsh --shims)"

if [[ -f "${ZDOTDIR:-$HOME}/.zshenv.local" ]]; then
  source "${ZDOTDIR:-$HOME}/.zshenv.local"
fi
