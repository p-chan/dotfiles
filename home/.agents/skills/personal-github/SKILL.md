---
name: personal-github
description: 個人の慣習とリポジトリの慣習に沿って GitHub を扱います。GitHub に関する作業をするときに必ず使用してください。
compatibility: gh、jq、curl が必要です
allowed-tools: Read(*), Bash(fd *), Bash(rg *), Bash(git fetch), Bash(git ls-remote *), Bash(git log:*), Bash(git log *), Bash(git rev-parse *), Bash(gh repo view *), Bash(gh issue list *), Bash(gh issue view *), Bash(gh issue create *), Bash(gh issue edit *), Bash(gh label list *), Bash(gh pr list *), Bash(gh pr view *), Bash(gh pr edit *), Bash(gh pr checks), Bash(gh review-comment list *), WebFetch(domain:docs.github.com)
---

# GitHub

個人の慣習とリポジトリの慣習に沿って GitHub を扱います。

## リファレンス

作業内容に応じて、該当するリファレンスをすべて読んでから、その内容に従います。

- `use-gh` - GitHub のリソースを読み書きするとき
- `create-pr` - PR を作成するとき
- `merge-pr` - PR をマージするとき
- `create-issue` - Issue を「作って」「起票して」などと依頼されたとき
- `clarify-issue` - 既存の Issue を「整理して」「書き直して」などと依頼されたとき
- `request-copilot-review` - Copilot にレビューを依頼するとき
- `upload-attachment` - Issue や PR にファイルを添付するとき
- `use-gh-review-comment` - レビュースレッドを確認・返信・解決するとき
- `pin-latest-version-sha` - GitHub Actions のワークフローにアクションを追加・変更・レビューするとき

## 使い方

各リファレンスは `references/` にあります。

```
references/create-pr.md
references/use-gh-review-comment.md
```
