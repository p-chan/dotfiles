##
# environments
##

# locale
set -x LANG ja_JP.UTF-8
set -x LC_ALL ja_JP.UTF-8

# editor
set -x EDITOR vim

# nodebrew
set -x PATH $HOME/.nodebrew/current/bin $PATH


# google cloud sdk
if test -f "$HOME/google-cloud-sdk/path.fish.inc"
    source "$HOME/google-cloud-sdk/path.fish.inc"
end

##
# aliases
##

alias c "code"
alias g "git"
alias n "npm"
alias v "vim"
alias y "yarn"

alias bx "bundle exec"

alias funcs "functions-emulator"

##
# functions
##

function zoi -d "Ganbaruzoi"
    cd (ghq root)/(ghq list | fzf)
end

##
# others
##

# direnv
direnv hook fish | source

# rbenv
rbenv init - | source
