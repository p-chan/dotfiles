---
name: personal-setup-pnpm
description: プロジェクトに pnpm 環境をセットアップします。packageManager フィールドの設定、pnpm-workspace.yaml での追加設定、既存パッケージマネージャーからの移行、CI の pnpm セットアップを行います。pnpm のセットアップを求められたときに使用してください。
---

# pnpm セットアップ

## ワークフロー

1. 現状の検出
2. `packageManager` フィールドの設定
3. `pnpm-workspace.yaml` での追加設定
4. モノレポ構成の確認・移行（該当する場合）
5. 既存ロックファイルと `node_modules` の削除（移行の場合）
6. `pnpm install` の実行
7. CI の更新

## 1. 現状の検出

以下を確認する。

- `package.json` がない場合は `pnpm init` で生成する
- 既存のパッケージマネージャーを特定する（`package-lock.json` → npm、`yarn.lock` → yarn、`pnpm-lock.yaml` → pnpm 導入済み、いずれもなし → 新規）
- `bun.lockb` / `bun.lock` が検出された場合は bun からの移行はこのスキルの対象外であることをユーザーに伝え、作業を中断する
- `package.json` の `workspaces` フィールドや `pnpm-workspace.yaml` からモノレポかどうかを判断する
- CI ワークフロー（`.github/workflows/`）が存在するか確認する
- アプリケーション用途か公開ライブラリ用途かを判断する。`package.json` の `private` フィールドや `main`/`exports` フィールドの有無、README の記述、それまでの会話の文脈などから判断できる場合はそれに従う。新規プロジェクトでこれらの材料がなく、判断に自信が持てない場合のみユーザーに確認する

## 2. `packageManager` フィールドの設定

`npm view pnpm version` で pnpm の最新バージョンを確認する（インストール済みのバージョンではなく、必ずこの時点の最新版を使う）。
確認した最新バージョンを `package.json` の `packageManager` フィールドに記述する。

```json
{
  "packageManager": "pnpm@x.y.z"
}
```

pnpm はデフォルト設定（`pmOnFail: download`）により、`packageManager` フィールドと実際にインストールされているバージョンが異なる場合、次回実行時に自動でそのバージョンをダウンロードして切り替える。手動でのインストールやアップデートは不要。
Corepack は使用しない。

## 3. `pnpm-workspace.yaml` での追加設定

[references/config.md](references/config.md) に従う。
pnpm は `.npmrc` からは認証・レジストリ関連の設定のみを読み込むため、それ以外の設定は `pnpm-workspace.yaml` に書く。モノレポの場合はステップ4で作成・更新する `pnpm-workspace.yaml` と同じファイルになる。

## 4. モノレポ構成の確認・移行（該当する場合）

モノレポの場合は [references/monorepo.md](references/monorepo.md) を参照する。
pnpm 導入済みのモノレポでは、`pnpm-workspace.yaml` が存在するか確認し、カタログ機能の適用も検討する。

## 5. 既存ロックファイルと `node_modules` の削除（移行の場合）

- pnpm 以外のパッケージマネージャーが検出された場合は [patterns/migration.md](patterns/migration.md) に従う
- pnpm 導入済みの場合はこのステップをスキップする（`pnpm-lock.yaml` はそのまま維持する）

## 6. `pnpm install` の実行

`pnpm install` を実行して依存関係をインストールし、`pnpm-lock.yaml` を生成する。
エラーが出た場合は内容を確認し、必要に応じて `pnpm-workspace.yaml` の設定を調整する（詳細は [references/config.md](references/config.md)）。

## 7. CI の更新

[references/ci.md](references/ci.md) に従う。
