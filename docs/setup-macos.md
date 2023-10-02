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

| Category          | Name                     | Note                                                                                       |
| :---------------- | :----------------------- | :----------------------------------------------------------------------------------------- |
| Business          | Slack                    |                                                                                            |
|                   | Zoom                     |                                                                                            |
| Developer Tools   | VSCode                   | [Document](./vscode.md)                                                                    |
|                   | Docker for Mac           | [Document](./docker-for-mac.md)                                                            |
|                   | Sequel Pro               |                                                                                            |
|                   | Postico                  |                                                                                            |
|                   | GraphiQL                 |                                                                                            |
|                   | Insomnia                 |                                                                                            |
|                   | Cyberduck                |                                                                                            |
|                   | ImageOptim               |                                                                                            |
| Graphics & Design | Sketch                   |                                                                                            |
|                   | Abstract                 |                                                                                            |
|                   | Figma                    |                                                                                            |
|                   | IconJar 2                |                                                                                            |
|                   | RightFont 5              |                                                                                            |
|                   | Adobe Photoshop 2020     | Require Adobe Creative Cloud                                                               |
|                   | Adobe Illustrator 2020   | Require Adobe Creative Cloud                                                               |
|                   | Adobe XD                 | Require Adobe Creative Cloud                                                               |
| Music             | Spotify                  |                                                                                            |
|                   | DaftCloud                | From App Store                                                                             |
|                   | Loopback 2               |                                                                                            |
|                   | LadioCast                |                                                                                            |
| News              | NewNewsWire 5            |                                                                                            |
| Productivity      | 1Password                | Install first                                                                              |
|                   | Fantastical              |                                                                                            |
|                   | Mimestream               |                                                                                            |
|                   | Things 3                 | From App Store                                                                             |
| Utilities         | Chrome                   | Install first                                                                              |
|                   | Firefox                  |                                                                                            |
|                   | Edge                     |                                                                                            |
|                   | Alfred 4                 | Hotkey: `Ctrl + Space`                                                                     |
|                   | App Cleaner              |                                                                                            |
|                   | iStat Menus 6            | [Document](./istat-menus-6.md)                                                             |
|                   | Google Drive File Stream |                                                                                            |
|                   | Logicool Options         | [Document](./logicool-options.md)                                                          |
|                   | Karabiner-Elements       | [Settings](../.macos/karabiner)                                                            |
|                   | Google Japanese Input    | TODO: Add document                                                                         |
|                   | Adobe Creative Cloud     |                                                                                            |
| Social Networking | Discord                  |                                                                                            |
|                   | Tweetbot 3               | From App Store                                                                             |
|                   | BathyScaphe              | Install Beta version from [Bitbucket](https://bitbucket.org/bathyscaphe/public/downloads/) |

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
