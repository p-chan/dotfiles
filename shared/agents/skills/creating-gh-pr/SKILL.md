---
name: creating-gh-pr
description: GitHub の PR を作成します。ユーザーが PR の作成を求めたときや、エージェントが PR を作成するときに使用してください。
allowed-tools: Bash(gh-notify-checks), Bash(gh request-review-to-copilot), Bash(gh-notify-copilot-review)
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

### 2. 作成

```sh
gh pr create \
  --assignee @me \
  --body <body> \
  --title <title>

# 状況に応じて他のオプションも追加できます
```

### 3. 作成後

以下を順に質問し、ユーザーが肯定した場合に実行します。

1. チェックが終了したときに通知するか？ → `gh-notify-checks` をバックグラウンドで実行
2. Copilot にレビューをリクエストするか？ → `gh request-review-to-copilot` を実行
3. Copilot がレビューしたときに通知するか？ → `gh-notify-copilot-review` をバックグラウンドで実行
