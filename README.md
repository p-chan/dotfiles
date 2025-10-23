# dotfiles

> The dotfiles for fuckin' awesome development environment

## Supported environments

- macOS 14 or later (Apple Silicon only)
- GitHub Codespaces (requires VSCode with the GitHub Codespaces extension)

## Install

### macOS

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/p-chan/dotfiles/main/scripts/install.sh)"
```

### GitHub Codespaces

Requires Automatically install dotfiles to be enabled and Settings Sync to be
disabled in GitHub Codespaces settings.

```sh
# Install VSCode extensions to GitHub Codespaces
deno run -A "$DOTFILES_DIR/scripts/code-extensions.ts" import
```

## Setup

### 1Password

#### Settings

- General
  - ☐ Keep 1Password in the menu bar
  - ✅ Start at login
  - ✅ Format secure notes using Markdown
  - ✅ Prefill username when creating new login
  - Default Vault
    - Save new items in: **Suggest a vault**
  - Kayboard Shortcuts
    - Use default
  - Autofill
    - ✅ Submit automatically with Universal Autofill
- Appearance
  - Theme: **Match system**
  - ✅ Use device accent color
  - Density
    - **Compact**
  - Interface Zoom
    - 100%
  - Always Show in Sidebar
    - ✅ Categories
    - ✅ Tags
- Secutiry
  - Auto-lock
    - Lock after the computer is idle for: **Never**
    - ☐ Lock on sleep, screensaver, or switching users
    - ☐ Allow 1Password to prevent your device from sleeping
  - Clipboard
    - ✅ Remove copied information and one-time passwords after 90 seconds
    - ✅ Use Universal Clipboard to copy to other devices
  - Concealed Fields
    - ☐ Always show passwords and full credit card numbers
    - ✅ Hold Option to toggle revealed fields
    - ✅ Always show Wi-Fi QR codes
- Privacy
  - ✅ Show app and website icons
  - Item Location
    - ☐ Use Apple Maps to search for location
  - Watchtower
    - ✅ Check for compromised websites
    - ☐ Check for vulnerable passwords
    - ✅ Check for two-factor authentication
    - ✅ Check for passkeys
- Browser
  - ✅ Connect with 1Password in the browser
- Developer
  - 1Password Developer
    - ☐ Show 1Password Developer experience
  - SSH Agent
    - ✅ Use the SSH Agent
    - Advanced
      - Ask approval for each new: **application and terminal session**
      - Remember key approval: **until 1Password quits**
      - ✅ Display key names when authorizing connections
      - ☐ Generate SSH config file with bookmarked hosted
      - Open SSH URLs with: **Ghostty**
  - Command-Line Interface (CLI)
    - ✅ Integrate with 1Password CLI
  - Watchtower
    - ☐ Check for developer credentials on disk

### Arc

#### Extensions

- [1Password](https://chromewebstore.google.com/detail/aeblfdkhhhdcdjpifhhbdiojplfjncoa)
- [Google Translate](https://chromewebstore.google.com/detail/aapbdbdomjkkjkaonfhkkikfgjllcleb)
- [Just Tweet Button](https://chromewebstore.google.com/detail/feikojefkpembojkeegfajbbfecocddd)
- [Keepa](https://chromewebstore.google.com/detail/neebplgakaahbhdphmkckjjcegoiijjo)
- [Wappalyzer](https://chromewebstore.google.com/detail/gppongmhjkpfnbhagpmjfkannfbllamg)

## Maintenance

### Homebrew

#### Upgrade packages

```sh
brew update
brew upgrade
```

### mise

#### Upgrade tools

```sh
mise up
```

## Author

[@p-chan](https://github.com/p-chan)

## License

[MIT License](LICENSE)
