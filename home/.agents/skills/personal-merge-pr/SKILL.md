---
name: personal-merge-pr
description: ユーザーが PR のマージを求めたときや、エージェントが PR をマージするときに必ず使用してください。
allowed-tools: Bash(gh review-comment list *), Bash(gh pr checks), Bash(gh repo view *), Bash(git fetch), Bash(git log *)
---

# GitHub PR マージ

## ワークフロー

### 未 push のコミットを確認する

以下のコマンドで、ローカルにあってリモートにないコミットを確認します。

```sh
git fetch
git log origin/$(git branch --show-current)..HEAD --oneline
```

未 push のコミットがある場合は、PR に反映されていない変更が存在する可能性があるため、ユーザーに確認します。

### レビューコメントを確認する

以下のコマンドで、未解決のレビューコメントがあるか確認します。

```sh
gh review-comment list --unresolved
```

未解決のレビューコメントがある場合は、ユーザーに対応の要否を確認します。

### チェックを確認する

`gh pr checks` で、チェックが成功しているか確認します。

保留中や失敗の場合は、ユーザーに対応の要否を確認します。

### マージ方法を確認する

以下を実行して許可されているマージ方法を取得します。

```bash
gh repo view --json mergeCommitAllowed,squashMergeAllowed,rebaseMergeAllowed
```

許可されているマージ方法が 1 つだけの場合、それを使用します。
許可されているマージ方法が複数の場合、ユーザーにどれを使うか質問します。

### マージする

`gh pr merge` でマージします。

先程取得したマージ方法に応じてオプションを付けます。

- Merge: `--merge` オプション
- Rebase: `--rebase` オプション
- Squash: `--squash` オプション

また `--delete-branch` オプションを付けてマージと同時にブランチを削除します（このオプションを使うと、自動でベースブランチに切り替わります）。

> [!WARNING]
> `--repo` オプションは `--delete-branch` オプションを無効化するため、他リポジトリの PR をマージするときに限り、使用します。
