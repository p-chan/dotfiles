# CI への typecheck ジョブ追加

## 既存の CI ワークフローがある場合

`.github/workflows/` に lint やテストなどを実行する CI 全般のワークフローが存在する場合、そのワークフローに `typecheck` ジョブを追加する。

- Node.js のセットアップ方法、パッケージマネージャー、キャッシュ設定など、既存の他ジョブのスタイルに合わせる
- ジョブ内では、採用したパターンで追加した `typecheck` スクリプトを実行する

## 既存の CI ワークフローがない場合

`.github/workflows/` に、`typecheck` を実行する最小限のワークフローを新規作成する。
[personal-github-actions-best-practices スキル](../../personal-github-actions-best-practices/SKILL.md)に従い、`actions/checkout` などのバージョンを SHA で固定する。

```yaml
name: CI

on:
  push:
    branches: [<デフォルトブランチ>]
  pull_request:

jobs:
  typecheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<SHA> # <最新タグ>
      - uses: actions/setup-node@<SHA> # <最新タグ>
        with:
          node-version-file: .node-version # 実際のファイルに合わせる
      - run: <検出したパッケージマネージャーのインストールコマンド>
      - run: <typecheck スクリプトの実行コマンド>
```

pnpm を使う場合の `pnpm/action-setup` の要否など、パッケージマネージャー固有のセットアップは検出した内容に合わせる（詳細は [personal-setup-pnpm スキル](../../personal-setup-pnpm/references/ci.md)を参照）。

## モノレポの場合

[monorepo.md](monorepo.md) の「CI」を参照する。
