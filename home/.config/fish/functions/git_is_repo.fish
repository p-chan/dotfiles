function git_is_repo
    if not command git rev-parse --is-inside-work-tree &>/dev/null
        return 1
    end
end
