alias g="git"

if type sheldon &>/dev/null; then
  eval "$(sheldon source)"
fi

if type starship &>/dev/null; then
  eval "$(starship init zsh)"
fi
