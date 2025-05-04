function release_as -d "create Release-As commit for release-please"
    # https://github.com/googleapis/release-please#how-do-i-change-the-version-number
    git commit --allow-empty -m "chore: release $argv" -m "Release-As: $argv"
end
