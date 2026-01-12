---
name: merging-gh-pr
description: ユーザーが PR のマージを求めたときや、エージェントが PR をマージするときに必ず使用してください。
allowed-tools: Bash(gh get-review-comments), Bash(gh pr checks), Bash(gh get-allowed-merge-methods)
---

# GitHub PR マージ

## ワークフロー

### レビューコメントを確認する

`gh get-review-comments` で、すべてのレビューコメントが解決済みか確認します。

未解決のレビューコメントがある場合は、ユーザーに対応の要否を確認します。

### チェックを確認する

`gh pr checks` で、チェックが成功しているか確認します。

保留中や失敗の場合は、ユーザーに対応の要否を確認します。

### マージ方法を確認する

`gh get-allowed-merge-methods` で許可されているマージ方法を取得します。

許可されているマージ方法が 1 つだけの場合、それを使用します。
許可されているマージ方法が複数の場合、ユーザーにどれを使うか質問します。

### マージする

`gh pr merge` でマージします。

先程取得したマージ方法に応じてオプションを付けます。

- Merge: `--merge` オプション
- Rebase: `--rebase` オプション
- Squash: `--squash` オプション

また `--delete-branch` オプションを付けてマージと同時にブランチを削除します（このオプションを使うと、自動でベースブランチに切り替わります）。
