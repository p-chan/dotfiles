# locale
set -x LANG ja_JP.UTF-8
set -x LC_ALL ja_JP.UTF-8

# nodebrew
set -x PATH $HOME/.nodebrew/current/bin $PATH

# rbenv
rbenv init - | source
