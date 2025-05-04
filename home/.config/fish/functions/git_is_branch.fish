function git_is_branch
    printf "%s" (command git symbolic-ref --short HEAD)
end
