# エディタ拡張の設定

oxlint と oxfmt は VS Code 拡張を共有する（拡張機能 ID: `oxc.oxc-vscode`）。

## `.vscode/extensions.json`

`recommendations` に追加する。

```json
{
  "recommendations": ["oxc.oxc-vscode"]
}
```

`esbenp.prettier-vscode` / `biomejs.biome` が含まれている場合は削除する。`dbaeumer.vscode-eslint` は、ESLint を並行運用する場合（[migration.md](migration.md)）を除き削除する。

## `.vscode/settings.json`

保存時フォーマットを有効化する場合は以下を追加する。

```json
{
  "editor.defaultFormatter": "oxc.oxc-vscode",
  "editor.formatOnSave": true
}
```

`editor.defaultFormatter` が `esbenp.prettier-vscode` や `biomejs.biome` など他の値になっている場合は置き換える。
