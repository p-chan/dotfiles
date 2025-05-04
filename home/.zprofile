if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if type mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi
