# .npmrc の設定

基本的には `.npmrc` を作成しない。pnpm のデフォルト設定（厳格な依存関係解決）をそのまま使う。

`pnpm install` 後にエラーや動作不良が出た場合のみ、以下の設定を追加する。

## 設定リファレンス

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
