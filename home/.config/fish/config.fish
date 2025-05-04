# locale
set -x LANG ja_JP.UTF-8

# editor
set -x EDITOR vim

# aliases
source "$HOME/.config/fish/aliases.fish"

# paths
source "$HOME/.config/fish/paths.fish"

# 1Password
if type -q "op"
  op completion fish | source
end

# direnv
if type -q "direnv"
  direnv hook fish | source
end

# rbenv
if type -q "rbenv"
  rbenv init - | source
end

# pyenv
if type -q "pyenv"
  pyenv init - | source
end

# nodenv
if type -q "nodenv"
  nodenv init - | source
end

# google cloud sdk
if type -q "gcloud"
  set -x CLOUDSDK_PYTHON /opt/homebrew/bin/python3
end

# fish

## Install fzf key bindings and fuzzy completion
## https://github.com/junegunn/fzf?tab=readme-ov-file#using-homebrew
if not test -f "$HOME/.config/fish/functions/fzf_key_bindings.fish"
    set PREFIX (brew --prefix)
    "$PREFIX/opt/fzf/install"
end

## secret scripts
if test -f "$HOME/.config/fish/secret.fish"
    source "$HOME/.config/fish/secret.fish"
end
