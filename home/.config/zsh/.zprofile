if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [[ -f "${ZDOTDIR:-$HOME}/.zprofile.local" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile.local"
fi
