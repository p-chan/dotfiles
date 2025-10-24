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

### Arc

#### Extensions

- [1Password](https://chromewebstore.google.com/detail/aeblfdkhhhdcdjpifhhbdiojplfjncoa)
- [Google Translate](https://chromewebstore.google.com/detail/aapbdbdomjkkjkaonfhkkikfgjllcleb)
- [Just Tweet Button](https://chromewebstore.google.com/detail/feikojefkpembojkeegfajbbfecocddd)
- [Keepa](https://chromewebstore.google.com/detail/neebplgakaahbhdphmkckjjcegoiijjo)
- [Wappalyzer](https://chromewebstore.google.com/detail/gppongmhjkpfnbhagpmjfkannfbllamg)

### Logi Options+

- LOG IN
- Click MX Master 3S
- Click SETTINGS from sidebar
- Click RESTORE SETTINGS FROM BACKUP under Restore backup

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
