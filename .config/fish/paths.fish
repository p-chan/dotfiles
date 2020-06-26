# homebrew
set -x PATH /usr/local/sbin $PATH

# direnv
direnv hook fish | source

# rbenv
rbenv init - | source

# nodenv
status --is-interactive
and source (nodenv init -|psub)

# google cloud sdk
source "$HOME/google-cloud-sdk/path.fish.inc"
