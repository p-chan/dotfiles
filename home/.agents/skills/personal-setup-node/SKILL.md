---
name: personal-setup-node
description: プロジェクトの Node.js バージョンをセットアップします。.node-version を作成・更新するときに必ず使用してください。
---

# Node.js バージョンのセットアップ

## ワークフロー

### 1. `.node-version` を生成

```bash
mise fnv [<version>]
```

- `<version>` を省略すると `latest` の Node.js バージョンが使われる
- メジャーバージョンのみ指定も可能（例: `mise fnv 20`）

### 2. インストール

```bash
mise install
```

`.node-version` を置いただけではインストールされない場合があるため、明示的に実行して結果を確認する。
