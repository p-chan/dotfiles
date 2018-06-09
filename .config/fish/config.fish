##
# environments
##

# locale
set -x LANG ja_JP.UTF-8
set -x LC_ALL ja_JP.UTF-8

# nodebrew
set -x PATH $HOME/.nodebrew/current/bin $PATH

##
# aliases
##

alias bx 'bundle exec'

##
# functions
##

function apme -d 'Export atom packages'
  apm list --installed --bare > ~/.atom/Atomfile
end

function apmi -d 'Import atom packages'
  apm install --packages-file ~/.atom/Atomfile
end

##
# others
##

# rbenv
rbenv init - | source
