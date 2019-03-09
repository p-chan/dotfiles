function npm_install
    set -l use_npm_version 6

    if not test npm
        printf "[error] npm is required"
        return $status
    end

    npm i -g npm@$use_npm_version

    set -l packages\
 @adonisjs/cli\
 @google-cloud/functions-emulator\
 @vue/cli\
 commitizen\
 cz-conventional-changelog\
 fixpack\
 knex\
 npm-check-updates\
 serve

    for package in $packages
        npm i -g $package
    end
end
