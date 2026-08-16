---
allowed-tools: Bash(zed:*), Bash(git rev-parse:*)
description: 現在のワークツリーのルートを Zed で開く
---

1. `git rev-parse --show-toplevel` でワークツリーのルートを取得します
2. `zed <ワークツリーのルート>` を実行します

Git リポジトリの外にいる場合は `zed .` を実行します。

実行後の報告は不要です。
