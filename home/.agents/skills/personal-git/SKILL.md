---
name: personal-git
description: 個人の慣習とリポジトリの慣習に沿って Git を扱います。Git に関する作業をするときに必ず使用してください。
compatibility: git-wt が必要です
allowed-tools: Bash(git status), Bash(git status *), Bash(git diff), Bash(git diff *), Bash(git diff:*), Bash(git log:*), Bash(sed:*), Bash(tr:*), Bash(sort:*), Bash(xargs:*), Read(*)
---

# Git

個人の慣習とリポジトリの慣習に沿って Git を扱います。

## リファレンス

作業内容に応じて、該当するリファレンスをすべて読んでから、その内容に従います。

- `create-commit` - コミットを作成するとき
- `create-branch` - ブランチや worktree を作成するとき
- `conventional-commits` - 判定したスタイルが Conventional Commits のとき
- `gitmoji` - 判定したスタイルが gitmoji のとき

## 使い方

各リファレンスは `references/` にあります。

```
references/create-commit.md
references/conventional-commits.md
```
