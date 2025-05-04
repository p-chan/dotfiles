function nnyv -d "Display versions of node, npm, yarn"
    # Utility
    set VERTICAL_LINE (set_color brblack)"|"

    # Prefix
    set NODE_PREFIX (set_color green)"⬢" (set_color white)"node"
    set NPM_PREFIX (set_color red)"■" (set_color white)"npm"
    set YARN_PREFIX (set_color cyan)"y" (set_color white)"yarn"

    # Initialize version
    set NODE_VERSION (set_color brblack)"undefined"
    set NPM_VERSION (set_color brblack)"undefined"
    set YARN_VERSION (set_color brblack)"undefined"

    # Update version
    if test (which node)
        set NODE_VERSION (node -v)
    end

    if test (which npm)
        set NPM_VERSION "v"(npm -v)
    end

    if test (which yarn)
        set YARN_VERSION "v"(yarn -v)
    end

    # Concat prefix and version
    set NODE_TEXT "$NODE_PREFIX $NODE_VERSION"
    set NPM_TEXT "$NPM_PREFIX $NPM_VERSION"
    set YARN_TEXT "$YARN_PREFIX $YARN_VERSION"

    # Output
    echo $NODE_TEXT $VERTICAL_LINE $NPM_TEXT $VERTICAL_LINE $YARN_TEXT
end
