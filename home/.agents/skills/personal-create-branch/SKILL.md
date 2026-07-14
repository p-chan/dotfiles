---
name: personal-create-branch
description: Git リポジトリの慣習に則って新しいブランチや worktree を作成します。ユーザーがブランチや worktree の作成を求めたときや、エージェントが `git branch` や `git switch -c`、`git worktree add` などを用いて新しい作業を開始するときに必ず使用してください。
allowed-tools: Bash(git status), Bash(git status *), Bash(git diff), Bash(git diff *), Bash(git config --local --get *)
---

# Git ブランチ・worktree 作成

## 前提

メモリファイル（`AGENTS.md` や `CLAUDE.md` など）にブランチ名の規約がある場合は、メモリファイルに従います。

## ワークフロー

### 1. worktree 運用の確認

[personal-detect-git-convention スキル](../personal-detect-git-convention/SKILL.md)の手順に従い、`convention.use-worktree` を確認します。

```bash
git config --local --get convention.use-worktree
```

- `true` の場合: worktree を作成します（ステップ 4-a）
- `false` の場合: 現在の working tree にブランチを作成します（ステップ 4-b）
- 未設定の場合: personal-detect-git-convention スキルの手順で判定・キャッシュしてから、その結果に従います

worktree を使うかどうかは、常に規約に従って判断します。「ブランチを作って」のような依頼は、worktree を使うかどうかの指定ではありません（worktree の作成はブランチの作成を兼ねます）。規約より優先するのは、ユーザーが worktree を使う・使わないに直接言及した場合だけです。

### 2. 情報収集

今までのコンテキストをもとに、作業の目的を理解します。

コンテキストが不足している場合は `git status` や `git diff` で情報収集して、作業の目的を理解します。

### 3. ブランチ名生成

作業の目的をもとに 2〜5 単語程度のブランチ名を生成します。

- 動詞で始める（`add`、`update`、`fix`、`remove` など）
- スラッシュを使わない
- ハイフンで区切る
- 変更内容を簡潔に表現する

**例**

- add-foo
- fix-bar
- update-baz
- remove-qux

### 4-a. worktree 作成

生成されたブランチ名を表示し、worktree を作成します。ブランチが存在しない場合は、ブランチも同時に作成されます。

```bash
git wt <branch-name>
```

`git wt` は作成した worktree のパスを出力します。以降の作業は、出力されたパスに移動して行います。

> [!NOTE]
> シェル統合が有効なインタラクティブシェルでは自動で移動しますが、エージェントの実行環境では自動で移動しないため、明示的に `cd` してください。

### 4-b. ブランチ作成

生成されたブランチ名を表示し、ブランチを作成します。

```bash
git switch -c <branch-name>
```
