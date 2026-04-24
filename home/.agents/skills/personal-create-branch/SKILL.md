---
name: personal-create-branch
description: Git リポジトリの慣習に則って新しいブランチを作成します。ユーザーがブランチの作成を求めたときや、エージェントが `git branch` や `git checkout -b`、`git switch -c` などを用いてブランチを作成するときに必ず使用してください。
allowed-tools: Bash(git status), Bash(git status *), Bash(git diff), Bash(git diff *)
---

# Git ブランチ作成

## 前提

メモリファイル（`AGENTS.md` や `CLAUDE.md` など）にブランチ名の規約がある場合は、メモリファイルに従う。

## ワークフロー

### 1. 情報収集

今までのコンテキストをもとに、ブランチの目的を理解します。

コンテキストが不足している場合は `git status` や `git diff` で情報収集して、ブランチの目的を理解します。

### 2. ブランチ名生成

ブランチの目的をもとに 2〜5 単語程度のブランチ名を生成します。

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

生成されたブランチ名を表示し、ブランチを作成します。

```bash
git switch -c <branch-name>
```
