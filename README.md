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
  - ✅ Keep 1Password in the menu bar
  - Click the icon to: **Show a menu**
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

- Sign in
- Right-click the sidebar, then deselect Live Folder > GitHub
- Open [arc://settings/languages](arc://settings/languages) and set Preferred
  languages to:
  1. Japanese
  2. English (United States)

#### Settings

- General
  - ☐ Automatically update my Arc
  - ✅ Warn before quitting
  - Previews
    - Show Arc Previews:
      - ☐ Arc Folders
      - ☐ Google Calendar
      - ☐ Google Mail
      - ☐ Outlook Calendar
      - ☐ Outlook Mail
      - ☐ Recent pages on Linear, Notion, and Figma
      - ☐ Notion Calendar
- Profiles
  - Default
    - Search engines **Google**
    - Manage search
      - Use defaults
    - ✅ Include search engine suggestions
    - Archive tabs after **24 hours**
    - New documents **-**
    - Download location **Downloads**
- Max
  - Disable all
- Links
  - ✅ Open Little ARc when I press ⌥⌘N in any app
  - ✅ Open Little Arc when clicking on links with ⌥⌘ held
  - ✅ Links from other apps open in Little Arc
  - Archive Little Arcs after: **12 hours**
  - ✅ Open a Peek window then clicking on links with Shift held
  - ✅ Open a Peek window then clicking on links to other sites
  - Choose where links open inside Arc.
    - Air Traffic Control
      - URL **Contains** **meet.google.com** Open in **Most Recent Space**
      - Default **Little Arc**
- Shortcuts
  - Use defaults
- Icon
  - **The Original Arc**
- Advanced
  - ✅ Play Arc sound effect
  - ✅ Haptic feedback when reordering tabs
  - ☐ When opening Arc, restore windows from previous session
  - ✅ Allow window dragging from the top of webpages
  - ☐ Show full URL when Toolbar is enabled
  - ✅ Enable Shared Quotes when highlighting text.
  - ✅ Enable Picture in Picture when you leave a video tab
  - ✅ Allow websites to get your theme data
  - ✅ Enable Boosts on websites you visit

#### Extensions

- [1Password](https://chromewebstore.google.com/detail/aeblfdkhhhdcdjpifhhbdiojplfjncoa)
- [Google Translate](https://chromewebstore.google.com/detail/aapbdbdomjkkjkaonfhkkikfgjllcleb)
- [Just Tweet Button](https://chromewebstore.google.com/detail/feikojefkpembojkeegfajbbfecocddd)
- [Keepa](https://chromewebstore.google.com/detail/neebplgakaahbhdphmkckjjcegoiijjo)
- [Wappalyzer](https://chromewebstore.google.com/detail/gppongmhjkpfnbhagpmjfkannfbllamg)
  (📌)

### Fantastical

- Sign in
- From the menu bar, choose **Fantastical / Enter Fantastical 2 License...**,
  enter my
  [Fantastical 2 License](https://start.1password.com/open/i?a=LM5F3GUMXZESHA52XDBWU2IBH4&v=qmldmb6wi6rv7qu5sxemwffyv4&i=5o5nin542zeypoi23lcofldfqm&h=my.1password.com),
  then click **License**

### Logi Options+

- LOG IN
- Click MX Master 3S
- Click SETTINGS from sidebar
- Click RESTORE SETTINGS FROM BACKUP under Restore backup

### iStat Menus

- Download
  [iStat Menus Settings](https://start.1password.com/open/i?a=LM5F3GUMXZESHA52XDBWU2IBH4&v=qmldmb6wi6rv7qu5sxemwffyv4&i=tme5ajhzmclm76utvqtcvw43ci&h=my.1password.com)
- From the menu bar, Click **File / Import settings...** and Select
  `iStat Menu
  Settings.ismp7`
- Arrange menu bar icons in the following order: **CPU & GPU**, **Memory**,
  **SSD**, and **Sensor**

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
