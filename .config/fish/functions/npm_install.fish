function npm_install
  set -l use_npm_version 5

  if not test npm
    printf "[error] npm is required"
    return $status
  end

  npm i -g npm@$use_npm_version

  set -l packages\
    @adonisjs/cli\
    commitizen\
    cz-conventional-changelog\
    fixpack\
    npm-check-updates

  for package in $packages
    npm i -g $package
  end
end
