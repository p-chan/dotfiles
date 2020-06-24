# Setup macOS

## Table of Contents

1. [Xcode](#1.-xcode)
2. [dotfiles](#2.-dotfiles)
3. [macOS defaults](#3.-macos-defaults)
4. [Homebrew](#4.-homebrew)
5. [Languages](#5.-languages)
6. [Applications](#6.-applications)
7. [Fonts](#7.-fonts)

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

- Clone dotfiles repository
  - `git clone git@github.com:p-chan/dotfiles.git ~/src/github.com/p-chan/dotfiles`
- Deploy dotfiles to home directory
  - `make deploy`

## 3. macOS defaults

- Setup System Preferences
- Setup Finder settings
- Reboot

## 4. Homebrew

- Install Homebrew
  - `/bin/bash -c "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"`
- Install Formulas (Use Brewfile)
  - `brew bundle`
- Install Google Cloud SDK from [Google Cloud](https://cloud.google.com/sdk/install)

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

Install Chrome and 1Password first.

| Category          | Name                     | Note                         |
| :---------------- | :----------------------- | :--------------------------- |
| Business          | Slack                    |                              |
|                   | Zoom                     |                              |
| Developer Tools   | VSCode                   |                              |
|                   | iTerm2                   |                              |
|                   | Docker for Mac           |                              |
|                   | Sequel Pro               |                              |
|                   | Postico                  |                              |
|                   | GraphiQL                 |                              |
|                   | Insomnia                 |                              |
|                   | Cyberduck                |                              |
|                   | ImageOptim               |                              |
| Graphics & Design | Sketch                   |                              |
|                   | Abstract                 |                              |
|                   | Figma                    |                              |
|                   | IconJar 2                |                              |
|                   | RightFont 5              |                              |
|                   | Adobe Photoshop 2020     | Require Adobe Creative Cloud |
|                   | Adobe Illustrator 2020   | Require Adobe Creative Cloud |
|                   | Adobe XD                 | Require Adobe Creative Cloud |
| Music             | Spotify                  |                              |
|                   | DaftCloud                |                              |
|                   | Loopback 2               |                              |
|                   | LadioCast                |                              |
| News              | NewNewsWire 5            |                              |
| Productivity      | 1Password                | Install first                |
|                   | Fantastical              |                              |
|                   | Mimestream               |                              |
|                   | Things 3                 |                              |
| Utilities         | Chrome                   | Install first                |
|                   | Firefox                  |                              |
|                   | Edge                     |                              |
|                   | Alfred 4                 |                              |
|                   | App Cleaner              |                              |
|                   | iStat Menus 6            |                              |
|                   | Google Drive File Stream |                              |
|                   | Logicool Options         |                              |
|                   | Karabiner-Elements       |                              |
|                   | Google Japanese Input    |                              |
|                   | Adobe Creative Cloud     |                              |
| Social Networking | Discord                  |                              |
|                   | Tweetbot 3               |                              |
|                   | BathyScaphe              |                              |

<small>Note: Categories are based on the App Store</small>

## 7. Fonts

- [Source Han Code JP](https://github.com/adobe-fonts/source-han-code-jp)
- Other from Google Drive fonts directory

---

## Screenshots

### Dock

TBD

### Launchpad

TBD
