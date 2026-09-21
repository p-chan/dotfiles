---
name: personal-git
description: リポジトリの慣習に合わせて Git の操作（コミット、ブランチ・worktree の作成）を行い、その前提となる規約（言語、コミットメッセージ・PR タイトルのスタイル、ブランチ戦略、worktree 運用）を検出します。ユーザーがコミットやブランチ・worktree の作成を求めたとき、エージェントがコミットするときや `git branch`、`git switch -c`、`git worktree add` などで新しい作業を開始するとき、Git の規約について尋ねられたとき、他のスキルが規約判定を必要とするときに必ず使用してください。
allowed-tools: Bash(git status), Bash(git status *), Bash(git diff), Bash(git diff *), Bash(git diff:*), Bash(git log:*), Bash(git log *), Bash(git config --local --get *), Bash(git config --local convention.language *), Bash(git config --local convention.commit-message-style *), Bash(git config --local convention.pull-request-title-style *), Bash(git config --local convention.branch-strategy *), Bash(git config --local convention.use-worktree *), Bash(sed:*), Bash(tr:*), Bash(sort:*), Bash(xargs:*), Bash(gh issue list *), Bash(gh pr list *), Bash(gh repo view *), Bash(gh api repos/*/branches/*/protection*), Bash(fd *), Read(*)
---

# Git

作業内容に応じて、対応するリファレンスをすべて読んでから、その手順に従います。

- **コミットの作成**: [references/commit.md](references/commit.md)、[references/convention.md](references/convention.md)、判定したコミットメッセージスタイルのリファレンス（[references/conventional-commits.md](references/conventional-commits.md) または [references/gitmoji.md](references/gitmoji.md)）
- **ブランチ・worktree の作成**: [references/create-branch.md](references/create-branch.md)、[references/convention.md](references/convention.md)
- **リポジトリの規約の検出・参照**: [references/convention.md](references/convention.md)
- **Conventional Commits 形式の文章の作成（他のスキルからの参照を含む）**: [references/conventional-commits.md](references/conventional-commits.md)
