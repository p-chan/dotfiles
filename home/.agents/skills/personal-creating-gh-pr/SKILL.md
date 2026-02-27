---
name: personal-creating-gh-pr
description: GitHub の PR を作成します。ユーザーが PR の作成を求めたときや、エージェントが PR を作成するときに使用してください。
compatibility: Claude Code
allowed-tools: Bash(gh-notify-checks), Bash(gh add-reviewer-copilot), Bash(gh-notify-copilot-review), Bash(gh pr checks), Bash(gh run view:*), Bash(gh run rerun:*), Bash(gh review-comment list)
---

# GitHub PR 作成

## 要件

- 言語は過去の PR に合わせる
- タイトル
  - What を簡潔に書く
  - フォーマット（プレフィックスの有無や種類など）は過去の PR に合わせる
- 本文
  - テンプレートがある場合はそれに沿う
  - テンプレートが複数ある場合
    - 適切なものが判断できる場合はそれを選ぶ
    - 適切なものが判断できない場合はユーザーに聞く
  - テンプレートがない場合は Why と What の詳細を書く
- `@me` にアサインする

## ワークフロー

### 1. 事前調査

過去の PR のタイトルを確認して、言語やフォーマットを判定します。

```sh
gh pr list --state all --limit 10 --json title --jq '.[].title'
```

テンプレートの有無を確認します。

- `.github/pull_request_template.md`
- `.github/PULL_REQUEST_TEMPLATE/*.md`

### 2. プッシュ

現在のブランチがリモートにプッシュ済みか確認します。

```sh
git ls-remote --heads origin <branch-name>
```

出力が空の場合はプッシュします。

```sh
git push -u origin <branch-name>
```

### 3. 作成

```sh
gh pr create \
  --assignee @me \
  --body "$body" \
  --title "$title"
```

**補足**

- 状況に応じて他のオプションも追加できます
- タイトルの言語と本文の言語は合わせます
  - タイトルが英語なら、本文も英語
  - タイトルが日本語なら、本文も日本語

### 4. 作成後

以下を質問し、ユーザーが肯定した場合に実行します。

1. チェックが終了したときに通知するか？ → Bash ツールで `run_in_background: true` を指定して `gh-notify-checks` を実行
2. Copilot にレビューをリクエストするか？ → `gh add-reviewer-copilot` を実行
3. Copilot がレビューしたときに通知するか？ → Bash ツールで `run_in_background: true` を指定して `gh-notify-copilot-review` を実行

### 4. バックグラウンド処理完了後

#### チェック終了通知を受け取ったら

`gh pr checks` で結果を確認します。

**成功した場合**

チェックが成功したことを伝えます。

**失敗した場合**

- `gh run view <run-id> --log-failed` でログを確認します
- PR の内容に問題がある場合は、修正を提案します
- PR の内容に問題がない場合は `gh run rerun <run-id> --failed` でジョブを再実行します

#### Copilot レビュー通知を受け取ったら

以下のコマンドでレビューコメントを取得します。

```sh
gh review-comment list
```
