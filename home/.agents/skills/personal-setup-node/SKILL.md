---
name: personal-setup-node
description: プロジェクトの Node.js バージョンをセットアップします。.node-version を作成・更新するときに必ず使用してください。
---

# Node.js バージョンのセットアップ

## ワークフロー

```bash
mise fnv [<version>]
```

- `<version>` を省略すると `latest` の Node.js バージョンが使われる
- メジャーバージョンのみ指定も可能（例: `mise fnv 20`）
- 未インストールのバージョンでも、`node` 等を実行した時点で mise が自動インストールするため、別途 `mise install` を叩く必要はない
