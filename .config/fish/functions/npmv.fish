function npmv -d "npm version"
    if test $argv
        npm i -g npm@$argv
    else
        echo "Required version"
    end
end
