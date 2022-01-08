# homebrew
if test -d "/usr/local/sbin"
  set -x PATH /usr/local/sbin $PATH
end

# composer
if test -d "$HOME/.composer"
  set -x PATH "$HOME/.composer/vendor/bin" $PATH
end

# deta
if test -d "$HOME/.deta"
  set -x PATH "$HOME/.deta/bin" $PATH
end

# google cloud sdk
if type -q "gcloud"
  source "$HOME/google-cloud-sdk/path.fish.inc"
end
