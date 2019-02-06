function node_install
    set -l use_node_version 10

    if not test nodebrew
        printf "[error] nodebrew is required"
        return $status
    end

    nodebrew install-binary v$use_node_version
    nodebrew use v$use_node_version
end
