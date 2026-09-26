# dotfiles

> The dotfiles for fuckin' awesome development environment

## 対応環境

- macOS 26 以降（Apple Silicon のみ）

## インストール

最初に **System Settings > General > Software Update** を開き、macOS を最新バージョンにアップデートします。
新品の Mac や再インストールした直後の Mac では、アップデートのカタログが古く、最新バージョンに直接アップデートできないことがあります。
その場合は、[フルインストーラ](https://support.apple.com/en-us/HT201475)を使うか、提示される中間のバージョンを順にインストールします。

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/p-chan/dotfiles/main/scripts/install.sh)"
```

リポジトリは、デフォルトで `~/src/github.com/p-chan/dotfiles` にクローンされます。
別の場所（CI、一時的な macOS 環境、既存のチェックアウトなど）を使うときは、`DOTFILES_DIR` を指定します。

```sh
DOTFILES_DIR="$PWD" bash scripts/install.sh
```

`install.sh` は、この場所を mise の `dotfiles.root` 設定として `home/.config/mise/conf.d/dotfiles-root.toml`（マシン固有で、Git の管理対象外）に記録します。
そのため、以降は環境変数を設定しなくても `mise bootstrap` を実行できます。
あとでチェックアウトの場所を変えるときは、ディレクトリを移動してから、新しいパスを `DOTFILES_DIR` に指定して `install.sh` を再実行します。

## Herdr の Claude 連携

`mise bootstrap` は、Claude Code 向けの Herdr 連携をインストールします。
Herdr はフックに絶対パスを要求するので、Git のインデックスには移植可能な `$HOME` 形式で保持し、作業ツリーではローカルのパスに復元します。
生成されたフックはローカルに残ります。

## プロファイル

共通の設定は常に有効です。
マシン固有の動作は、以下のプロファイルの一方または両方で追加します。

| プロファイル | 用途                                               |
| :----------- | :------------------------------------------------- |
| `desktop`    | GUI アプリ、Dock と Finder の設定、エディタの設定  |
| `server`     | 無人でリモート操作するための常時稼働向けの電源設定 |

初回のインストールでは `desktop` が選ばれます。
ヘッドレスのサーバーにしたり、両方の役割を組み合わせたりするときは、`DOTFILES_PROFILES` を指定します。

```sh
DOTFILES_PROFILES=server \
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/p-chan/dotfiles/main/scripts/install.sh)"
DOTFILES_PROFILES=desktop,server \
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/p-chan/dotfiles/main/scripts/install.sh)"
```

選んだプロファイルは `home/.config/mise/conf.d/` 以下にマシン固有のシンボリックリンクとして保存されるので、以降の `mise bootstrap` や `install.sh` の実行でも維持されます。
あとで変更するときは、以下を実行します。

```sh
DOTFILES_PROFILES=desktop,server \
  bash "$DOTFILES_DIR/scripts/configure-profiles.sh" "$DOTFILES_DIR"
mise bootstrap
```

`server` プロファイルは、AC 電源接続時のアイドルによるシステムスリープを無効にし、停電後の自動再起動を有効にしたうえで、System Settings で Remote Login が有効になるまで待機します。
初回の適用には管理者パスワードが必要です。
これらの設定だけを適用するときは、`mise run bootstrap-server` を実行します。
プロファイルを外すと、その設定は管理対象から外れますが、パッケージのアンインストールや macOS の設定の復元は自動では行いません。

## セットアップ

Homebrew でインストールする GUI アプリの一覧です。
**設定ファイル**はこのリポジトリがシンボリックリンクする設定のパスで、**ドキュメント**はインストール後に手作業で行う手順へのリンクです。

| アプリ              | ログイン時に起動 | 設定ファイル                  | ドキュメント                                                         |
| :------------------ | :--------------- | :---------------------------- | :------------------------------------------------------------------- |
| 1Password           | ✅               | —                             | [docs/apps/1password.md](docs/apps/1password.md)                     |
| Arc                 | ☐                | —                             | [docs/apps/arc.md](docs/apps/arc.md)                                 |
| ChatGPT             | ☐                | —                             | —                                                                    |
| Claude              | ☐                | —                             | —                                                                    |
| CleanShot X         | ✅               | —                             | —                                                                    |
| CodexBar            | ✅               | —                             | —                                                                    |
| Cyberduck           | ☐                | —                             | —                                                                    |
| Docker Desktop      | ✅               | —                             | —                                                                    |
| Fantastical         | ✅               | —                             | [docs/apps/fantastical.md](docs/apps/fantastical.md)                 |
| Figma               | ☐                | —                             | [docs/apps/figma.md](docs/apps/figma.md)                             |
| Ghostty             | ☐                | `~/.config/ghostty`           | —                                                                    |
| Google Chrome       | ☐                | —                             | [docs/apps/chrome.md](docs/apps/chrome.md)                           |
| Google Japanese IME | ☐                | —                             | [docs/apps/google-japanese-ime.md](docs/apps/google-japanese-ime.md) |
| Handy               | ✅               | —                             | [docs/apps/handy.md](docs/apps/handy.md)                             |
| iStat Menus         | ✅               | —                             | [docs/apps/istat-menus.md](docs/apps/istat-menus.md)                 |
| Karabiner-Elements  | ✅               | `~/.config/karabiner`         | —                                                                    |
| Logi Options+       | ✅               | —                             | [docs/apps/logi-options-plus.md](docs/apps/logi-options-plus.md)     |
| Mimestream          | ☐                | —                             | —                                                                    |
| Raycast             | ✅               | —                             | —                                                                    |
| Slack               | ✅               | —                             | [docs/apps/slack.md](docs/apps/slack.md)                             |
| Zed                 | ☐                | `~/.config/zed/settings.json` | —                                                                    |

新しいマシンを使える状態にするまでに必要なアプリは、ごく一部です。
他のドキュメントからリンクしている認証情報とライセンスキーのための 1Password、他のサービスにサインインするためのメインのブラウザである Arc、キーボードとマウスの入力のための Karabiner-Elements、Google Japanese IME、Logi Options+、ランチャーの Raycast があれば十分です。
残りのアプリは、実際に必要になってからで構いません。

## メンテナンス

### アップグレード

Homebrew のパッケージと mise のツールをアップグレードします。

```sh
dots up
```

## 作者

[@p-chan](https://github.com/p-chan)

## ライセンス

[MIT License](LICENSE)
