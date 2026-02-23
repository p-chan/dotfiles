# AGENTS.md

- 日本語で会話する
- 文字コードは UTF-8 を使用する

## GitHub

GitHub にアクセスするときは、必ず `gh` コマンドを使います。

### エイリアス

| エイリアス                | 概要                             |
| :------------------------ | :------------------------------- |
| `gh add-reviewer-copilot` | Copilot をレビュアーに追加する。 |

### 拡張機能

#### [gh-review-comment](https://github.com/p-chan/gh-review-comment)

レビューコメントを操作するための gh 拡張機能です。

| コマンド                                        | 概要                             | 補足                                       |
| :---------------------------------------------- | :------------------------------- | :----------------------------------------- |
| `gh review-comment list`                        | レビュースレッド一覧を表示する。 |                                            |
| `gh review-comment reply <commentId> -b <body>` | レビューコメントに返信する。     |                                            |
| `gh review-comment resolve <threadId>`          | レビュースレッドを解決する。     | `threadId` は `PRRT_` から始まる ID です。 |

### `gh-notify-*` コマンドリファレンス

GitHub で非同期で実行される処理の終了を監視して通知するコマンドです。

| コマンド                   | 概要                               |
| :------------------------- | :--------------------------------- |
| `gh-notify-checks`         | チェックが終了したら通知する。     |
| `gh-notify-copilot-review` | Copilot がレビューしたら通知する。 |
