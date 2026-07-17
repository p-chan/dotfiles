---
name: personal-merge-pr
description: ユーザーが PR のマージを求めたときや、エージェントが PR をマージするときに必ず使用してください。
allowed-tools: Bash(gh review-comment list *), Bash(gh pr checks), Bash(gh pr list *), Bash(gh pr edit *), Bash(gh repo view *), Bash(git fetch), Bash(git log *), Bash(git rev-parse *)
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

`gh pr checks` でチェックのステータスを確認し、以下のルールに従って行動します。

| ステータス                   | 行動                                                                  |
| ---------------------------- | --------------------------------------------------------------------- |
| `pass` / `skipping` のみ     | 次のステップへ進む                                                    |
| `pending` が含まれる         | `gh pr checks --watch` で完了まで待機し、結果に応じて再判定           |
| `fail` / `cancel` が含まれる | 失敗しているチェックの URL を確認して原因を特定し、ユーザーに報告する |

### マージ方法を確認する

以下を実行して許可されているマージ方法を取得します。

```bash
gh repo view --json mergeCommitAllowed,squashMergeAllowed,rebaseMergeAllowed
```

許可されているマージ方法が 1 つだけの場合、それを使用します。
許可されているマージ方法が複数の場合、ユーザーにどれを使うか質問します。

### Squash Merge 時のコミットメッセージを確認して、必要に応じて修正する

> このステップは Squash Merge のときのみ実行します。

GitHub の Squash Merge は、ブランチのコミット数によってマージ後のコミットメッセージが変わります。

| ブランチのコミット数 | マージ後のコミットメッセージ |
| -------------------- | ---------------------------- |
| 1 件                 | ブランチのコミットメッセージ |
| 複数件               | PR タイトル                  |

コミットが 1 件のとき、PR タイトルとコミットメッセージが異なっていると意図しないコミットメッセージでマージされる可能性があります。そのため、以下を確認して、必要に応じて修正します。

```sh
# コミット数
git log <base-branch>..HEAD --oneline | wc -l

# コミットメッセージ（1件目のタイトル）
git log <base-branch>..HEAD --format="%s" | head -1

# PR タイトル
gh pr view --json title -q .title
```

コミットが 1 件かつ PR タイトルとコミットメッセージが異なる場合は、どちらに合わせるかユーザーに確認します。

- PR タイトルに合わせる場合は `git commit --amend` でコミットメッセージを修正してから force push します
- コミットメッセージに合わせる場合は `gh pr edit --title` で PR タイトルを修正します

### 依存する PR がないか確認する

マージ対象のブランチを base にしている、他のオープンな PR がないか確認します。

```sh
gh pr list --base "$(git branch --show-current)" --state open
```

> [!WARNING]
> GitHub の Web UI でマージ・ブランチ削除を行った場合、依存する PR の base ブランチはマージ先へ自動的に付け替わります（[Pull Request Retargeting](https://github.blog/changelog/2020-05-19-pull-request-retargeting/)）。しかし `gh pr merge --delete-branch`（や `git push origin --delete` によるブランチ削除）はこの自動付け替えを発火させない既知の問題があり（[cli/cli#1168](https://github.com/cli/cli/issues/1168)）、依存する PR は base ブランチが失われて自動的にクローズされます。base が失われた PR は reopen も base の付け替えもできず、実質的に復旧できません。

依存する PR が見つかった場合、ブランチを削除する**前に**、それぞれの base をマージ先ブランチへ付け替えます。

```sh
gh pr edit <PR番号> --base <マージ先ブランチ名>
```

付け替えが完了してから、後続のマージ・削除の手順に進みます。
依存する PR がない場合は、そのまま次に進んで構いません。

### マージする

`gh pr merge` でマージします。

先程取得したマージ方法に応じてオプションを付けます。

- Merge: `--merge` オプション
- Rebase: `--rebase` オプション
- Squash: `--squash` オプション

マージ時・マージ後の後片付けは、現在のディレクトリが linked worktree かどうかで手順が変わります。以下のコマンドで判定します。

```sh
test "$(git rev-parse --git-dir)" != "$(git rev-parse --git-common-dir)" && echo "linked worktree" || echo "main working tree"
```

#### main working tree の場合

`--delete-branch` オプションを付けてマージと同時にブランチを削除します（このオプションを使うと、自動でベースブランチに切り替わります）。

> [!WARNING]
> `--repo` オプションは `--delete-branch` オプションを無効化するため、他リポジトリの PR をマージするときに限り、使用します。

#### linked worktree の場合

`--delete-branch` オプションは付けません。ベースブランチが別の worktree でチェックアウトされているため、マージ後のブランチ切り替えに失敗します。

マージ後、マージしたブランチ名（`git branch --show-current`）を控えたうえで、以下の手順で worktree とローカルブランチを削除します。

```sh
# main working tree に移動する
cd "$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"

# worktree とローカルブランチを削除する
git wt -d <branch-name>
```

リモートブランチは、リポジトリの Automatically delete head branches 設定が有効なら自動で削除されます。以下のコマンドで確認し、`false` の場合のみ手動で削除します。

```sh
gh repo view --json deleteBranchOnMerge -q .deleteBranchOnMerge
```

```sh
git push origin --delete <branch-name>
```
