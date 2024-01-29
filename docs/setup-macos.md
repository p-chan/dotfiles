# Setup macOS

## Table of Contents

1. [Xcode](#1-xcode)
2. [dotfiles](#2-dotfiles)
3. [macOS defaults](#3-macos-defaults)
4. [Homebrew](#4-homebrew)
5. [Languages](#5-languages)
6. [Applications](#6-applications)
7. [Fonts](#7-fonts)

- [Screenshots](#screenshots)
  - [Dock](#dock)
  - [Launchpad](#launchpad)

## 1. Xcode

- Install Xcode from App Store
- Read Xcode license and agree
  - `sudo xcodebuild -license`
  - `agree`

<small>Note: I can use git command when installed Xcode</small>

## 2. dotfiles

- Generate ssh key and ssh config for GitHub
  - `ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -C "" -N ""`
  - `pbcopy < ~/.ssh/id_rsa.pub`
  - `echo -e "Host github.com\n\tHostName github.com\n\tIdentityFile ~/.ssh/id_rsa\n\tUser git" > ~/.ssh/config`
- Register public key to GitHub
  - [Add new SSH keys](https://github.com/settings/ssh/new) to GitHub
- Verify authentication from GitHub
  - `ssh -T github.com`
  - `Hi p-chan! You've successfully authenticated, but GitHub does not provide shell access.`
- Clone dotfiles repository
  - `git clone git@github.com:p-chan/dotfiles.git ~/src/github.com/p-chan/dotfiles`
- Delete temporary .ssh directory
  - `rm -rf ~/.ssh`
- Link dotfiles to home directory
  - `cd ~/src/github.com/p-chan/dotfiles`
  - `sh link.sh`

## 3. macOS defaults

- Setup System Preferences
  - `sh .macos/finder/settings.sh`
- Setup Finder settings
  - `sh .macos/system-preferences/settings.sh`
- Reboot

## 4. Homebrew

- Install Homebrew
  - `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"`
- Install Formulas (Use Brewfile)
  - `brew bundle`

## 5. Languages

### Node.js

- Install Node.js
  - `nodenv install x.x.x`
  - `nodenv global x.x.x`
- Check Node.js and npm version
  - `node -v`
  - `npm -v`

### Ruby

- Install Ruby
  - `rbenv install x.x.x`
  - `rbenv global x.x.x`
- Check Ruby and gem version
  - `ruby -v`
  - `gem -v`

## 6. Applications

- From
  - :beer:: Homebrew
  - :apple:: Mac App Store
  - :wave:: Manually

| Category          | Name                                | From    | Note                                            |
| :---------------- | :---------------------------------- | :------ | :---------------------------------------------- |
| Books             | Amazon Kindle                       | :apple: |                                                 |
| Business          | Slack                               | :beer:  |                                                 |
|                   | Zoom                                | :beer:  |                                                 |
| Developer Tools   | Android Studio                      | :beer:  |                                                 |
|                   | Cyberduck                           | :beer:  |                                                 |
|                   | Docker Desktop                      | :beer:  | [Document](./docker-desktop/README.md)          |
|                   | Hyper                               | :beer:  |                                                 |
|                   | ImageOptim                          | :beer:  |                                                 |
|                   | Insomnia                            | :beer:  |                                                 |
|                   | Postico                             | :beer:  |                                                 |
|                   | Sequel Ace                          | :beer:  |                                                 |
|                   | VSCode                              | :beer:  | [Document](./vscode/README.md)                  |
|                   | Xcode                               | :apple: |                                                 |
| Graphics & Design | Adobe Creative Cloud                | :beer:  |                                                 |
|                   | Figma                               | :beer:  |                                                 |
| Music             | Spotify                             | :beer:  |                                                 |
| News              | NewNewsWire                         | :beer:  |                                                 |
| Productivity      | 1Password                           | :beer:  | TODO: Add document                              |
|                   | Fantastical                         | :beer:  | TODO: Add document                              |
|                   | Mimestream                          | :beer:  |                                                 |
|                   | Things                              | :apple: | [Document](./things/README.md)                  |
| Utilities         | AppCleaner                          | :beer:  |                                                 |
|                   | Google Chrome                       | :beer:  |                                                 |
|                   | Google Drive                        | :beer:  |                                                 |
|                   | Google Japanese Input               | :beer:  | TODO: Add document                              |
|                   | iStat Menus                         | :beer:  | [Document](./istat-menus/README.md)             |
|                   | Karabiner-Elements                  | :beer:  | [Settings](../.config/karabiner/karabiner.json) |
|                   | Logicool Options+                   | :beer:  | [Document](./logicool-options-plus/README.md)   |
|                   | One Drive                           | :beer:  |                                                 |
|                   | Raycasts                            | :beer:  | [Document](./raycast/README.md)                 |
|                   | Yamaha Steinberg USB Controll Panel | :wave:  |                                                 |
|                   | Yamaha ZG Controller                | :wave:  |                                                 |
| Social Networking | Discord                             | :beer:  |                                                 |

<small>Note: Categories are based on the App Store</small>

## 7. Fonts

- [Source Han Code JP](https://github.com/adobe-fonts/source-han-code-jp)
- Other from Google Drive fonts directory

---

## Screenshots

### Dock

TODO: Add screenshot

### Launchpad

TODO: Add screenshot
