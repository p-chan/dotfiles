# pnpm の追加設定

## 設定ファイルの置き場所

pnpm は `.npmrc` からは認証・レジストリ関連の設定のみを読み込む。それ以外の設定（`savePrefix`、`shamefullyHoist`、`publicHoistPattern`、`strictPeerDependencies` など）は `pnpm-workspace.yaml`（プロジェクト単位）または `~/.config/pnpm/config.yaml`（グローバル）に書く必要があり、`.npmrc` に書いても読み込まれない。

このスキルでは、プロジェクトに同梱してチームで共有できるよう、常にプロジェクト単位の `pnpm-workspace.yaml` に書く。

モノレポでない場合も、設定だけの目的で `pnpm-workspace.yaml` を作成してよい。`packages` フィールドを省略するとルートパッケージのみがワークスペースに含まれるため、単一パッケージのプロジェクトでも問題なく使える。

モノレポの場合は [references/monorepo.md](monorepo.md) で作成・使用する `pnpm-workspace.yaml` と同じファイルに追記する。

## 基本方針

基本的には設定を追加しない。pnpm のデフォルト設定（厳格な依存関係解決）をそのまま使う。

## `savePrefix`（exact 固定）

アプリケーション用途の場合はデフォルトで設定する。

```yaml
savePrefix: ""
```

npm の `save-exact` に相当する設定。pnpm には `save-exact` というキーはなく、`savePrefix`（デフォルト `"^"`）を空文字にすることで、依存関係のバージョンを `^`/`~` を付けずに完全固定でインストール・記録する。以下の理由で採用する。

- `package.json` を見るだけで実際に使われているバージョンが分かり、依存関係の可読性が上がる
- バージョンアップが必ず `package.json` の diff に現れるため、レビューで変更が追いやすい
- `pnpm-lock.yaml` のコンフリクトを解消するために lockfile を作り直すと、range 指定（`^1.2.3` など）の依存はその時点の最新版に再解決され、意図しないバージョンアップが混入する。exact 固定ならこの副作用が起きない

公開ライブラリ用途の場合は設定しない。
依存関係を exact 固定すると、ライブラリの利用者側で `node_modules` 内に重複バージョンが発生しやすくなり、dedupe が効かなくなるため。

## その他の設定リファレンス

`pnpm install` 後にエラーや動作不良が出た場合のみ、以下の設定を追加する。

### `strictPeerDependencies`

peer dependencies の不整合をエラーとして扱うかどうか。pnpm v9 以降はデフォルト `false`。
移行時に peer dependencies 関連のエラーが大量に出る場合、根本的な解決が困難なときは明示的に設定する。

```yaml
strictPeerDependencies: false
```

### `publicHoistPattern`

特定のパッケージをプロジェクトルートの `node_modules` にホイスティングする。
`shamefullyHoist: true` より影響範囲が小さいため、こちらを優先して使う。

```yaml
# 例: ESLint プラグインをホイスティングする場合
publicHoistPattern:
  - "*eslint*"
```

### `shamefullyHoist`

すべての依存関係をフラットにホイスティングする（npm と同等の動作）。
pnpm の厳格な依存関係解決を無効化するため、最終手段として使う。
使う場合はユーザーに確認してから設定する。

```yaml
shamefullyHoist: true
```
