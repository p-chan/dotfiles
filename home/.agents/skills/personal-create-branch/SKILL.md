---
name: personal-create-branch
description: ブランチを作成し、新しい worktree にチェックアウトします。ユーザーがブランチや worktree の作成を求めたときや、エージェントが `git branch`、`git switch -c`、`git worktree add` などでブランチや worktree を作成しようとするときに必ず使用してください。
compatibility: git-wt が必要です
allowed-tools: Bash(git status), Bash(git status *), Bash(git diff), Bash(git diff *)
---

# Git ブランチ作成

## 前提

リポジトリにブランチのルールがある場合は、そのルールを優先します。

## ワークフロー

### 1. 情報収集

今までのコンテキストをもとに、ブランチを作成する目的を理解します。

コンテキストが不足している場合は `git status` や `git diff` で情報収集して、ブランチを作成する目的を理解します。

### 2. ブランチ名生成

目的をもとに 2〜5 単語程度のブランチ名を生成します。

- 動詞で始める（`add`、`update`、`fix`、`remove` など）
- スラッシュを使わない
- ハイフンで区切る
- 変更内容を簡潔に表現する

**例**

- add-foo
- fix-bar
- update-baz
- remove-qux

### 3. ブランチ作成

ブランチを作成し、新しい worktree にチェックアウトします。

```bash
git wt <branch-name>
```

`git wt` は作成した worktree のパスを出力します。以降の作業は、出力されたパスに移動して行います。

> [!NOTE]
> シェル統合が有効なインタラクティブシェルでは自動で移動しますが、エージェントの実行環境では自動で移動しないため、明示的に `cd` してください。
