# CI への Node.js バージョンの反映

`.github/workflows/` に CI ワークフローが存在する場合のみ更新する。存在しない場合は何もしない。

## 反映手順

`actions/setup-node` を使っているステップで、バージョンを `node-version-file` から読むように統一する。

```yaml
- uses: actions/setup-node@<SHA> # <最新タグ>
  with:
    node-version-file: .node-version
```

`actions/setup-node` のバージョンは、[personal-github-actions-best-practices スキル](../../personal-github-actions-best-practices/SKILL.md)に従い、最新版を SHA で固定する。

## 既存の指定を置き換える場合

- `node-version` にバージョンが直書きされている場合は、その行を削除して `node-version-file` に置き換える。`node-version` と `node-version-file` の両方が指定されている場合、`actions/setup-node` は `node-version` を優先するため、直書きを残したままでは `.node-version` が反映されない
- `node-version-file` が `.nvmrc` を指している場合は `.node-version` に変更する（`.nvmrc` 自体はスキル本体のステップ1で削除する）
- マトリックスビルドで複数の Node.js バージョンを意図的に試している場合は、`.node-version` に寄せずにマトリックスの指定を維持する

## パッケージマネージャーのセットアップ

`pnpm/action-setup` やキャッシュ設定など、パッケージマネージャー側のセットアップは、[personal-setup-pnpm スキルの CI 手順](../../personal-setup-pnpm/references/ci.md)に従う。
