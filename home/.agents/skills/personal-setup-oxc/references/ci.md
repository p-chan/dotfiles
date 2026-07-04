# CI への lint/format-check ジョブ追加

## 既存の CI ワークフローがある場合

既存のワークフローに、手順6で追加した `lint` と `format:check` を実行するジョブを、それぞれ別ジョブとして追加する（どちらが落ちたか PR のステータスチェック一覧から一目で分かるようにするため）。
Node.js のセットアップ方法、パッケージマネージャー、キャッシュ設定など、既存の他ジョブのスタイルに合わせる。
ESLint、Prettier、Biome を実行していたジョブやステップがあれば置き換える。

## 既存の CI ワークフローがない場合

`.github/workflows/` に、`lint` と `format:check` を実行する最小限のワークフローを新規作成する。
[personal-github-actions-best-practices スキル](../../personal-github-actions-best-practices/SKILL.md)に従い、`actions/checkout` などのバージョンを SHA で固定する。

```yaml
name: CI

on:
  push:
    branches: [<デフォルトブランチ>]
  pull_request:

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<SHA> # <最新タグ>
      - uses: actions/setup-node@<SHA> # <最新タグ>
        with:
          node-version-file: .node-version # 実際のファイルに合わせる
      - run: <検出したパッケージマネージャーのインストールコマンド>
      - run: <lint スクリプトの実行コマンド>

  format-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<SHA> # <最新タグ>
      - uses: actions/setup-node@<SHA> # <最新タグ>
        with:
          node-version-file: .node-version # 実際のファイルに合わせる
      - run: <検出したパッケージマネージャーのインストールコマンド>
      - run: <format:check スクリプトの実行コマンド>
```

pnpm を使う場合の `pnpm/action-setup` の要否など、パッケージマネージャー固有のセットアップは手順1で検出した内容に合わせる（詳細は [personal-setup-pnpm スキル](../../personal-setup-pnpm/references/ci.md)を参照）。

## 共通

oxlint は GitHub Actions 環境を自動検出し、追加設定なしで PR 上に warning/error のアノテーションを表示する。

モノレポの場合も、ルートで `lint` / `format:check` を実行するだけで全パッケージが対象になる。
[migration.md](migration.md) の判断で ESLint を並行運用するパッケージがある場合は、そのパッケージの `lint:eslint` 相当のスクリプトを呼び出すステップも追加する。
