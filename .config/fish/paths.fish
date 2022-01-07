# homebrew
set -x PATH /usr/local/sbin $PATH

# google cloud sdk
source "$HOME/google-cloud-sdk/path.fish.inc"

# composer
set -x PATH ~/.composer/vendor/bin $PATH

# deta
if test -d "$HOME/.deta"
  set -x PATH "$HOME/.deta/bin" $PATH
end
