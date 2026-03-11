---
name: personal-use-gh-review-comment
description: gh コマンドの拡張機能である gh-review-comment を用いて GitHub のレビュースレッドを操作します。 ユーザーがレビュースレッドの操作を求めたときや、エージェントがレビュースレッドを操作するときに使います。
---

# [gh-review-comment](https://github.com/p-chan/gh-review-comment) を利用する

## 取得する

レビュースレッド一覧を取得するときは、以下のコマンドを実行します。

```sh
gh review-comment list
```

出力には以下の情報が含まれます。

- `threadId`: スレッドを解決するときに使用する ID（`PRRT_` から始まる）
- `commentId`: コメントに返信するときに使用する ID
- コメント本文、投稿者、解決済みかどうかなど

> [!TIP]
> `--unresolved` を付けると未解決のスレッドのみ表示できます。

## 返信する

レビューコメントに返信するときは、以下のコマンドを実行します。

```sh
gh review-comment reply <commentId> -b '<body>'
```

- `<commentId>`: `gh review-comment list` で確認した commentId を指定します
- `<body>`: 内容を指定します

> [!TIP]
> `<body>` はシングルクォートで囲みます。そうすることで、`!` や `$`、`` ` `` などの特殊文字がシェルに展開されるのを防げます。

## 解決する

レビュースレッドを解決するときは、以下のコマンドを実行します。

```sh
gh review-comment resolve <threadId>
```

- `<threadId>`: `gh review-comment list` で確認した threadId を指定します

## その他

> [!NOTE]
> その他、詳細は `gh review-comment -h` で確認できます。
