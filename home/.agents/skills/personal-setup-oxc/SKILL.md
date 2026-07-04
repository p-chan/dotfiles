---
name: personal-setup-oxc
description: プロジェクトに oxlint と oxfmt をセットアップします。既存の ESLint/Prettier/Biome からの移行、設定ファイルの作成、package.json への lint/format スクリプト追加、type-aware lint の有効化判断、エディタ拡張の設定、CI へのジョブ追加を行います。oxlint や oxfmt のセットアップを求められたときに使用してください。
---

# oxlint / oxfmt セットアップ

## 対象

既存のリンターとフォーマッターの設定は、create-xxx 系のスキャフォールドが生成する程度のものを主な対象とする。
個別の判断が必要な分岐（移行できないルールやプラグインの扱いなど）は [references/migration.md](references/migration.md) の各分岐でその都度ユーザーに確認する。

## ワークフロー

1. 現状の検出
2. `oxlint` のインストール
3. `oxfmt` のインストール
4. 既存のリンターとフォーマッターからの移行（該当する場合）
5. 設定ファイルの作成（必要な場合のみ）
6. package.json への lint/format スクリプト追加
7. type-aware lint の有効化判断
8. エディタ拡張の設定（該当する場合）
9. CI への追加

## 1. 現状の検出

以下を確認する。

- パッケージマネージャー（`packageManager` フィールドやロックファイル）とモノレポ構成か（`workspaces` フィールドや `pnpm-workspace.yaml` など）
- 既存のリンター（ESLint）、フォーマッター（Prettier）、統合ツール（Biome）の有無とその設定ファイル。モノレポの場合はルートだけでなく各パッケージも確認する
- `oxlint` と `oxfmt` が既にインストールされているか（一方だけ導入済みなど部分的な場合も含む）
- `.vscode/` ディレクトリの有無（手順8で使う）
- CI ワークフロー（`.github/workflows/`）の有無（手順9で使う）

## 2. oxlint のインストール

既にインストール済みの場合は最新バージョンに更新する。未導入の場合は `oxlint` の最新バージョンを devDependencies としてインストールする。
モノレポの場合はルートに1回だけインストールし、全パッケージで共有する。

## 3. oxfmt のインストール

既にインストール済みの場合は最新バージョンに更新する。未導入の場合は `oxfmt` の最新バージョンを devDependencies としてインストールする。
モノレポの場合はルートに1回だけインストールし、全パッケージで共有する。

## 4. 既存のリンターとフォーマッターからの移行（該当する場合）

[references/migration.md](references/migration.md) に従う。
既存のリンターとフォーマッターのどちらもない場合はこのステップをスキップする。

## 5. 設定ファイルの作成（必要な場合のみ）

基本的には設定を追加しない。oxlint と oxfmt はいずれもデフォルト設定のまま動作するよう設計されている。
移行元の設定を引き継ぐ必要がある場合、または個別の除外設定が必要な場合のみ、[references/config.md](references/config.md) に従って作成する。

## 6. package.json への lint/format スクリプト追加

`scripts` に以下を追加する。ESLint、Prettier、Biome を実行する同等のスクリプトが既にある場合は置き換える。

```json
{
  "scripts": {
    "lint": "oxlint",
    "lint:fix": "oxlint --fix",
    "format": "oxfmt",
    "format:check": "oxfmt --check"
  }
}
```

モノレポの場合もルートの `package.json` にのみ追加する。oxlint と oxfmt はいずれもディレクトリ単位で最も近い設定ファイルを適用しながらモノレポ全体を1コマンドで処理できるため、パッケージごとに設定や方針（手順4と7）が異なっていても集約スクリプトは1つでよい。ただし手順4で ESLint を並行運用するパッケージがある場合は、[references/migration.md](references/migration.md) に従ってそのパッケージ用の実行手段を別途追加する。

## 7. type-aware lint の有効化判断

プロジェクトが TypeScript を使用している場合、[references/type-aware.md](references/type-aware.md) に従って有効化を検討する。
モノレポでは `tsconfig.json` がルートになく各パッケージ配下にのみ存在することがあるため、ルートだけでなく各パッケージも確認する。`tsconfig.json` がどこにも存在しない場合はこのステップをスキップする。

## 8. エディタ拡張の設定（該当する場合）

`.vscode/` ディレクトリが既に存在する場合のみ、[references/editor.md](references/editor.md) に従って設定する。
存在しない場合は何もしない（新規に作成しない）。

## 9. CI への追加

[references/ci.md](references/ci.md) に従う。
