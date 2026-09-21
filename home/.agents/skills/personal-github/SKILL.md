---
name: personal-github
description: gh を用いて GitHub を操作（PR の作成・マージ、Issue の作成・整理、Copilot へのレビュー依頼、レビュースレッドの操作、添付ファイルのアップロード）し、GitHub Actions のワークフローを規約に沿って書きます。ユーザーやエージェントが PR を作成・マージするとき、Issue を「作って」「起票して」「整理して」「書き直して」などと依頼されたとき、Copilot にレビューを依頼するとき、レビューコメントを確認・返信・解決するとき、Issue や PR にファイルを添付するとき、GitHub Actions のワークフローやジョブ、ステップを追加・変更・レビューするときに必ず使用してください。
compatibility: gh、jq、curl が必要です
allowed-tools: Read(*), Bash(fd *), Bash(rg *), Bash(git config --local --get *), Bash(git config --local convention.language *), Bash(git ls-remote *), Bash(git fetch), Bash(git log:*), Bash(git log *), Bash(git rev-parse *), Bash(gh repo view *), Bash(gh issue list *), Bash(gh issue view *), Bash(gh issue create *), Bash(gh issue edit *), Bash(gh label list *), Bash(gh pr list *), Bash(gh pr view *), Bash(gh pr edit *), Bash(gh pr checks), Bash(gh review-comment list *), WebFetch(domain:docs.github.com)
---

# GitHub

作業内容に応じて、対応するリファレンスをすべて読んでから、その手順に従います。

- **PR の作成**: [references/create-pr.md](references/create-pr.md)（規約の判定と Conventional Commits の形式は personal-git スキルを使う）
- **PR のマージ**: [references/merge-pr.md](references/merge-pr.md)
- **Issue の作成**: [references/create-issue.md](references/create-issue.md)
- **既存 Issue の整理・再構成**: [references/clarify-issue.md](references/clarify-issue.md)
- **Copilot へのレビュー依頼**: [references/request-review-to-copilot.md](references/request-review-to-copilot.md)（指摘に返信・解決する場合は [references/review-comment.md](references/review-comment.md) も読む）
- **レビュースレッドの取得・返信・解決**: [references/review-comment.md](references/review-comment.md)
- **Issue や PR に貼るファイルのアップロード**: [references/upload-attachment.md](references/upload-attachment.md)
- **GitHub Actions のワークフローの追加・変更・レビュー**: [references/pin-latest-version-sha.md](references/pin-latest-version-sha.md)
