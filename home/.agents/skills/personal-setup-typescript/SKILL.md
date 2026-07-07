---
name: personal-setup-typescript
description: プロジェクトに TypeScript 環境をセットアップします。typescript（TypeScript 7 RC のネイティブコンパイラ）のインストール、適切な @tsconfig/bases の選定と tsconfig.json への反映、package.json への typecheck スクリプト追加、CI への typecheck ジョブ追加を行います。TypeScript のセットアップを求められたときに使用してください。
---

# TypeScript セットアップ

## 対象

npm/yarn/pnpm/bun のいずれかを使うプロジェクトを対象とする。
Deno は独自の TypeScript ツールチェイン（`deno check`）を持ち、`jsr:`/`npm:`/`https://` などの Deno 固有のモジュール指定子を `tsc` が解決できないため、このスキルの対象外とする。

## ワークフロー

1. パッケージマネージャー（とモノレポ構成）の検出
2. `typescript` のインストール
3. tsconfig を分割するか判断し、該当するパターンに従う
4. CI への `typecheck` ジョブ追加

## 1. パッケージマネージャー（とモノレポ構成）の検出

プロジェクトの `packageManager` フィールドやロックファイルから npm/yarn/pnpm/bun を検出する。
以降のインストールはすべてこのパッケージマネージャーで行う。

`package.json` の `workspaces` フィールドや `pnpm-workspace.yaml` などがあればモノレポと判断し、パッケージ一覧を検出する。
モノレポの場合の追加の考慮事項は [references/monorepo.md](references/monorepo.md) にまとめてあり、以降の手順とパターンは各パッケージに対して適用する。

## 2. typescript のインストール

`typescript` を `rc` タグ（TypeScript 7 RC）で devDependencies としてインストールする。

```
typescript@rc
```

TypeScript 7 RC 以降、[typescript-go](https://github.com/microsoft/typescript-go) 由来のネイティブコンパイラが標準の `typescript` パッケージに統合されており、CLI コマンド名は `tsc` である（`tsgo`/`@typescript/native-preview` は nightly 版向けのパッケージ名であり、RC 以降の通常導線では使わない）。

モノレポの場合はルートに1回だけインストールし、全パッケージで共有する（詳細は [references/monorepo.md](references/monorepo.md)）。

## 3. tsconfig を分割するか判断

プロジェクト内に、アプリケーションのソースコード（例: `src/`）とは異なる実行環境で動く TypeScript ファイルがあるか確認する。
典型例は、ブラウザ向けにビルドされる `src` とは別に、Node.js 上で直接実行されるビルドツールの設定ファイル（`vite.config.ts`、`vitest.config.ts` など）が存在するケースである。
たとえば Vite の公式テンプレートは、この理由で tsconfig を分割している。

モノレポの場合は、検出した各パッケージについてこの判断を行う。

判断できたら、該当するパターンに従う。

- 該当する場合: [patterns/split-tsconfig.md](patterns/split-tsconfig.md)
- 該当しない場合: [patterns/single-tsconfig.md](patterns/single-tsconfig.md)

## 4. CI への typecheck ジョブ追加

[references/ci.md](references/ci.md) に従う。
