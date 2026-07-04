# モノレポの場合の追加考慮事項

## `pnpm-workspace.yaml` の設定

pnpm のモノレポはルートに `pnpm-workspace.yaml` でワークスペースを定義する。

### 新規プロジェクト

`pnpm-workspace.yaml` を新規作成し、パッケージのディレクトリ構成に合わせてパターンを記述する。

```yaml
packages:
  - "packages/*"
  - "apps/*"
```

### npm / yarn からの移行

npm や yarn は `package.json` の `workspaces` フィールドでワークスペースを定義する。
pnpm も `workspaces` フィールドを読み取るが、`pnpm-workspace.yaml` への移行を推奨する（pnpm の公式な方法であり、ルートの `package.json` をシンプルに保てる）。

移行手順：

1. `package.json` の `workspaces` フィールドの内容を `pnpm-workspace.yaml` に移植する
2. `package.json` の `workspaces` フィールドを削除する

## カタログ機能

pnpm v9 以降では `pnpm-workspace.yaml` にカタログ（共通バージョン定義）を記述できる。
ステップ2で確認した pnpm バージョンが v9 以上であり、かつ既存の依存関係にバージョンの揺れがある場合に限り、カタログへの統一をユーザーに提案する。

```yaml
packages:
  - "packages/*"

catalog:
  react: ^19.0.0
  typescript: ^5.8.0
```

パッケージ側の `package.json` では `catalog:` プロトコルで参照する。

```json
{
  "dependencies": {
    "react": "catalog:"
  }
}
```

## `pnpm install` の実行

モノレポでは常にルートで `pnpm install` を実行する。全パッケージの依存関係が一括でインストールされる。
