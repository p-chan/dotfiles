# 他のパッケージマネージャーからの移行

create-\* コマンドで生成した直後のプロジェクトも含む。

## 共通手順

1. `node_modules` を削除する

## パッケージマネージャー別の作業

### npm からの移行

- `package-lock.json` を削除する
- モノレポの場合は `package.json` の `workspaces` フィールドを `pnpm-workspace.yaml` に移行する（[references/monorepo.md](../references/monorepo.md)）

### yarn からの移行

- `yarn.lock` を削除する
- `.yarnrc.yml`（yarn Berry）または `.yarnrc`（yarn Classic）があれば削除する
- yarn Berry の場合は `.pnp.cjs`、`.pnp.loader.mjs` も削除する
- yarn Berry 固有の設定（`nodeLinker` など）を確認し、不要なものを削除する
- `package.json` の `workspaces` フィールドはそのまま残しても pnpm は読み取るが、モノレポの場合は `pnpm-workspace.yaml` に移行する（[references/monorepo.md](../references/monorepo.md)）

## `pnpm install` 後のトラブルシューティング

### peer dependencies のエラー

`pnpm install` 時に peer dependencies のエラーが出る場合、根本的な解決（依存関係の追加など）が困難なときは `.npmrc` で無効化することをユーザーに確認する（[references/npmrc.md](../references/npmrc.md)）。

### hoisting が必要なパッケージ

pnpm はデフォルトで依存関係を厳格に解決するため、`require()` でパスを直接解決する古いパッケージが動作しないことがある。
`public-hoist-pattern` で対応できる場合はそちらを優先し、それでも解決できない場合のみ `shamefully-hoist=true` をユーザーに提案する（[references/npmrc.md](../references/npmrc.md)）。
