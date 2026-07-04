# CI の pnpm セットアップ

`.github/workflows/` に CI ワークフローが存在する場合のみ更新する。存在しない場合は何もしない。

## セットアップ手順

既存ジョブの Node.js セットアップステップを以下のパターンに置き換える。
`actions/checkout`、`pnpm/action-setup`、`actions/setup-node` のバージョンは、[personal-github-actions-best-practices スキル](../../personal-github-actions-best-practices/SKILL.md)に従い、最新版を SHA で固定する。

```yaml
- uses: actions/checkout@<SHA> # <最新タグ>
- uses: pnpm/action-setup@<SHA> # <最新タグ>
  # version は package.json の packageManager フィールドから自動読み取り
- uses: actions/setup-node@<SHA> # <最新タグ>
  with:
    node-version-file: .node-version # 実際のファイルに合わせる
    cache: pnpm
- run: pnpm install
```

`pnpm/action-setup` は `version` を指定しない場合、`package.json` の `packageManager` フィールドから pnpm バージョンを自動で読み取る。

pnpm は CI 環境を自動検出し、ロックファイルが存在する場合はデフォルトで `--frozen-lockfile` 相当の挙動になる（ロックファイルと `package.json` が同期していなければ失敗する）。そのため `--frozen-lockfile` を明示的に指定する必要はない。

Node.js のバージョン指定はプロジェクトの実態に合わせる。`.node-version` がある場合は `node-version-file` で指定する。
ない場合は [Node.js のリリーススケジュール](https://nodejs.org/en/about/previous-releases)でその時点の LTS バージョンを確認し、`node-version` に直書きする。

```yaml
# .node-version がある場合
node-version-file: .node-version

# ない場合（確認した LTS バージョンを指定）
node-version: "x.y"
```

## 既存ジョブの更新

既存ジョブが npm や yarn のキャッシュ設定を使っている場合は `cache: pnpm` に変更する。
`npm ci` や `yarn install --frozen-lockfile` を使っている場合は `pnpm install` に変更する。

## モノレポの場合

セットアップ手順はポリレポと同じ。ルートで `pnpm install` を実行するだけで全パッケージの依存関係がインストールされる。
