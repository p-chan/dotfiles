# Migrations

`git pull` だけでは既存のマシンに反映されない変更と、その反映の手順を記録します。

エントリは次の形式で末尾に追加します。

```md
### YYYY-MM-DD 変更の内容

対象: `desktop`（すべてのマシンが対象なら省略）

実行するコマンド（`dots up` など）と、手動の設定の上書きや再起動などの副作用
```

手順は、別のマシンで PR の文脈なしに実行できる形で書きます。エントリは書いた時点の記録として残し、あとから古くなってもそのままにします。

## エントリ

### 2026-11-02 Dock に ChatGPT と Claude を追加

対象: `desktop`

`mise run -C "$HOME" bootstrap-desktop` を実行する。Dock の項目を入れ直すので、手動で変えた Dock の並びは上書きされ、Dock は再起動する。言語や既定のブラウザなど、このタスクのほかの設定も再度適用される。

### 2026-11-03 codex-review スキルを追加

`agent-skills install codex-review` を実行する。

### 2026-11-03 p-chan/skills のスキルを追加し、重複する personal スキルを削除

`agent-skills install setup-node-version setup-oxc setup-pnpm setup-typescript dependencies github-actions setup-repo setup-skills setup-p-chan-skills` を実行する。personal-setup-node、personal-setup-oxc、personal-setup-pnpm、personal-setup-typescript、personal-installing-npm-packages は git pull で削除される。

### 2026-11-04 Icon Composer を追加

対象: `desktop`

`dots up` を実行する。

### 2026-11-04 Icon Composer の cask を削除

対象: `desktop`

Xcode に同梱の Icon Composer を使う。cask でインストール済みなら `brew uninstall --cask icon-composer` を実行する。

### 2026-11-08 OCI CLI を追加

`dots up` を実行する。

### 2026-11-10 markdown スキルを追加

`agent-skills install markdown` を実行する。

### 2026-11-21 Rust を追加

`mise install rust` を実行する。rustup が `~/.rustup` と `~/.cargo` に Rust のツールチェーンをインストールする。

### 2026-11-21 ランチャーを Raycast から Tinycast に変更

対象: `desktop`

`mise bootstrap` を実行して Tinycast をインストールし、`~/.config/tinycast/settings.json` をリンクする。すでに同じパスにファイルがあると衝突するので、その場合は削除してから実行する。そのあと [docs/apps/tinycast.md](docs/apps/tinycast.md) に沿って設定する。Raycast は `brew uninstall --cask raycast` でアンインストールする。

### 2026-11-21 p-chan/skills のスキルを更新

`agent-skills install changeset codex-review dependencies github-actions markdown playwright-cli-screenshot setup-node-version setup-oxc setup-p-chan-skills setup-pnpm setup-repo setup-skills setup-typescript` を実行する。

### 2026-11-21 mxm を追加

対象: `desktop`

`~/.config/mxm` がすでにあると衝突するので、中身を退避して削除してから `mise bootstrap` を実行し、`~/.config/mxm` をリンクする。そのあと `mise install github:p-chan/mxm` を実行すると、`postinstall` の `mxm service install` が mxm を常駐させる。初回だけ、表示された実行ファイルをシステム設定 → プライバシーとセキュリティ → 入力監視 と アクセシビリティ（ソフトウェアスクロール用）で許可する。

### 2026-11-21 Logi Options+ を削除

対象: `desktop`

mxm でマウスを設定するので、Logi Options+ を使わない。`sudo` がパスワードを聞くので、Claude Code の `!` ではなくターミナルで `brew uninstall --zap --cask logi-options+` を実行する。この cask は LogiPluginService と RightSight の起動設定を消さず、`/Library/Application Support/Logi` も残ることがあるので、続けて次を実行する。

```sh
launchctl bootout gui/$(id -u)/com.logitech.LogiRightSight.Agent
pkill -f LogiPluginService
sudo rm /Library/LaunchAgents/com.logitech.LogiRightSight.Agent.plist
sudo rm -rf /Applications/Utilities/LogiPluginService.app "/Library/Application Support/Logi"
sudo pkgutil --forget com.logi.installer.pluginservice.package
sudo pkgutil --forget com.logi.installer.pluginservice.media.package
```
