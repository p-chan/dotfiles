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
