# homebrew
if test -d "/opt/homebrew/bin"
  set -x PATH "/opt/homebrew/bin" $PATH
end

# composer
if test -d "$HOME/.composer"
  set -x PATH "$HOME/.composer/vendor/bin" $PATH
end

# deta
if test -d "$HOME/.deta"
  set -x PATH "$HOME/.deta/bin" $PATH
end

# pyenv
if test -d "$HOME/.pyenv"
  set -Ux PYENV_ROOT $HOME/.pyenv
  fish_add_path $PYENV_ROOT/bin
end

# google cloud sdk
if type -q "gcloud"
  source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.fish.inc"
end
