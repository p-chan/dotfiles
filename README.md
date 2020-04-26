# dotfiles

> The dotfiles for fuckin' awesome feeling development environment

## Requirement

- macOS 10.15.0+

## Setup

```bash
# Clone repository
$ git clone git@github.com:p-chan/dotfiles.git ~/src/github.com/p-chan/dotfiles

# Deploy to home directory
$ make deploy

# Install Command Line Tools for Xcode
$ xcode-select --install

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Git
$ brew install git
$ brew install ghq

# Vim
$ brew install vim

# fish shell
$ brew install fish

# Node.js
$ brew install nodenv
$ brew install nodenv/nodenv/nodenv-default-packages
$ nodenv install x.x.x
$ nodenv global x.x.x

# Ruby
# TBD
```

## Philosophy

- For development environment only (Don't include application settings not related to development)
- For setting preferences only (Don't pursue automation of setup)

## Author

[@p-chan](https://github.com/p-chan)

## License

[MIT License](LICENSE)
