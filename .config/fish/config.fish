# locale
set -x LANG ja_JP.UTF-8
set -x LC_ALL ja_JP.UTF-8

# editor
set -x EDITOR vim

# aliases
source "$HOME/.config/fish/aliases.fish"

# paths
source "$HOME/.config/fish/paths.fish"

# secret
if test -f "$HOME/.config/fish/secret.fish"
    source "$HOME/.config/fish/secret.fish"
end
