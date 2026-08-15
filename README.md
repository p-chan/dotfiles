# dotfiles

> The dotfiles for fuckin' awesome development environment

## Supported environments

- macOS 14 or later (Apple Silicon only)

## Install

Before anything else, open **System Settings > General > Software Update**
and update macOS to the latest version. On a brand-new Mac (or one that was
just reinstalled), the update catalog can be stale and block jumping straight
to the latest version — if that happens, install the
[full installer](https://support.apple.com/en-us/HT201475) or step through
the intermediate versions it offers first.

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/p-chan/dotfiles/main/scripts/install.sh)"
```

By default the repo is cloned to `~/src/github.com/p-chan/dotfiles`. To use
another location (CI, a temporary macOS environment, or an existing
checkout), set `DOTFILES_DIR`:

```sh
DOTFILES_DIR="$PWD" bash scripts/install.sh
```

`install.sh` records the location as mise's `dotfiles.root` setting in
`home/.config/mise/conf.d/dotfiles-root.toml` (machine-local, gitignored),
so plain `mise bootstrap` invocations need no environment setup afterwards.
To move the checkout later, move the directory and re-run `install.sh` with
`DOTFILES_DIR` pointing at the new path.

## Profiles

The shared configuration is always active. Machine-specific behavior is added
with one or both of these profiles:

| Profile   | Purpose                                                  |
| :-------- | :------------------------------------------------------- |
| `desktop` | GUI apps, Dock/Finder preferences, and editor settings   |
| `server`  | Always-on power settings for unattended remote operation |

The first install defaults to `desktop`. Select a headless server or compose
both roles with `DOTFILES_PROFILES`:

```sh
DOTFILES_PROFILES=server \
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/p-chan/dotfiles/main/scripts/install.sh)"
DOTFILES_PROFILES=desktop,server \
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/p-chan/dotfiles/main/scripts/install.sh)"
```

The selection is persisted as machine-local symlinks under
`home/.config/mise/conf.d/`, so subsequent `mise bootstrap` and `install.sh`
runs preserve it. To change the selection later, run:

```sh
DOTFILES_PROFILES=desktop,server \
  bash "$DOTFILES_DIR/scripts/configure-profiles.sh" "$DOTFILES_DIR"
mise bootstrap
```

The `server` profile disables idle system sleep on AC power and enables restart
after power loss. Its first convergence requires an administrator password; run
`mise run bootstrap-server` to apply only those settings. Removing a profile
stops managing its settings but does not uninstall packages or restore previous
macOS settings automatically.

## Setup

Configure applications that require manual setup:

- [1Password](docs/apps/1password.md)
- [Arc](docs/apps/arc.md)
- [Fantastical](docs/apps/fantastical.md)
- [Logi Options+](docs/apps/logi-options-plus.md)
- [iStat Menus](docs/apps/istat-menus.md)
- [Slack](docs/apps/slack.md)

## Maintenance

### Upgrade

Upgrade Homebrew packages and mise tools.

```sh
dots up
```

## Author

[@p-chan](https://github.com/p-chan)

## License

[MIT License](LICENSE)
