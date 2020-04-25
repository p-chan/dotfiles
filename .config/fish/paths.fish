# direnv
if type -q direnv
    direnv hook fish | source
end

# rbenv
if type -q rbenv
    rbenv init - | source
end

# nodenv
if type -q nodenv
    status --is-interactive
    and source (nodenv init -|psub)
end

# google cloud sdk
if type -q gcloud
    source "$HOME/google-cloud-sdk/path.fish.inc"
end
