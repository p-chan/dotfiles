---
name: creating-gh-pr
description: ユーザーが PR の作成を求めたときや、エージェントが PR を作成するときに必ず使用してください。
---

# GitHub PR 作成

## 作成するとき

- `gh pr create` を使います
- `@me` にアサインします

## 作成したあと

- チェックが終了したときに通知するか？を質問して、ユーザーが肯定した場合
  `gh-notify-checks` をバックグラウンドで実行します。
- Copilot にレビューをリクエストするか？を質問して、ユーザーが肯定した場合
  `gh request-review-to-copilot` を実行します。
- Copilot がレビューしたときに通知するか？を質問して、ユーザーが肯定した場合
  `gh-notify-copilot-review` をバックグラウンドで実行します。
