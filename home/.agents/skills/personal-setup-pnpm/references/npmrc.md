# .npmrc の設定

## `save-exact`

アプリケーション用途の場合はデフォルトで設定する。

```ini
save-exact=true
```

依存関係のバージョンを `^`/`~` を付けずに完全固定でインストール・記録する設定。以下の理由で採用する。

- `package.json` を見るだけで実際に使われているバージョンが分かり、依存関係の可読性が上がる
- バージョンアップが必ず `package.json` の diff に現れるため、レビューで変更が追いやすい
- `pnpm-lock.yaml` のコンフリクトを解消するために lockfile を作り直すと、range 指定（`^1.2.3` など）の依存はその時点の最新版に再解決され、意図しないバージョンアップが混入する。exact 固定ならこの副作用が起きない

公開ライブラリ用途の場合は設定しない。
依存関係を exact 固定すると、ライブラリの利用者側で `node_modules` 内に重複バージョンが発生しやすくなり、dedupe が効かなくなるため。

## その他の設定リファレンス

`pnpm install` 後にエラーや動作不良が出た場合のみ、以下の設定を追加する。

### `strict-peer-dependencies`

peer dependencies の不整合をエラーとして扱うかどうか。pnpm v9 以降はデフォルト `false`。
移行時に peer dependencies 関連のエラーが大量に出る場合、根本的な解決が困難なときは明示的に設定する。

```ini
strict-peer-dependencies=false
```

### `public-hoist-pattern`

特定のパッケージをプロジェクトルートの `node_modules` にホイスティングする。
`shamefully-hoist=true` より影響範囲が小さいため、こちらを優先して使う。

```ini
# 例: ESLint プラグインをホイスティングする場合
public-hoist-pattern[]=*eslint*
```

### `shamefully-hoist`

すべての依存関係をフラットにホイスティングする（npm と同等の動作）。
pnpm の厳格な依存関係解決を無効化するため、最終手段として使う。
使う場合はユーザーに確認してから設定する。

```ini
shamefully-hoist=true
```
