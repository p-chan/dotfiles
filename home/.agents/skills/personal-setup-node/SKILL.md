---
name: personal-setup-node
description: プロジェクトの Node.js バージョンをセットアップします。既存のバージョン指定の検出、LTS バージョンの選定と .node-version の生成、CI の Node.js セットアップへの反映を行います。.node-version を作成・更新するときや Node.js のバージョン指定を求められたときに使用してください。
---

# Node.js バージョンのセットアップ

## ワークフロー

1. 現状の検出
2. バージョンの決定
3. `.node-version` の生成
4. CI への反映

## 1. 現状の検出

以下を確認する。

- `.node-version` が存在するか（存在する場合は新規作成ではなく更新として扱う）
- `.nvmrc` が存在するか。mise は `.nvmrc` を `.node-version` より優先して読むため、両方が存在すると `.node-version` の指定が無視される。`.nvmrc` は削除して `.node-version` に一本化する
- `package.json` の `engines.node` が存在するか。存在する場合は、決定するバージョンがその範囲を満たすようにする
- `.github/workflows/` に CI ワークフローが存在するか

## 2. バージョンの決定

原則として Active LTS を使う。

Current（非 LTS）でしか使えない機能に依存しているなど、明確な理由がある場合に限り、特定のメジャーバージョンや `node@latest` を指定する。
その場合は、LTS を使わない理由をユーザーに伝える。

## 3. `.node-version` の生成

```bash
mise latest node@lts > .node-version
```

- `node@lts` は、その時点の Active LTS の最新パッチバージョンに解決される
- メジャーバージョンを固定する場合は `mise latest node@24 > .node-version` のように指定する
- `node@latest` は Current に解決されることがあるため、LTS を使う場合は `node@lts` を明示する
- `mise latest` は解決できないバージョンを指定しても、終了コード 0 のまま空文字列を返す。そのままリダイレクトすると `.node-version` が空になるため、生成後に中身が `x.y.z` 形式であることを必ず確認する
- 未インストールのバージョンでも、`node` 等を実行した時点で mise が自動インストールするため、別途 `mise install` を叩く必要はない

## 4. CI への反映

[references/ci.md](references/ci.md) に従う。
