---
name: personal-upload-attachment-to-github
description: ローカルのファイル（スクリーンショットや画面収録など）を GitHub にアップロードし、Issue や PR の本文に貼れる URL を取得します。ユーザーがファイルの添付や添付用 URL の取得を求めたときや、エージェントが Issue や PR にファイルを貼りたいときに使用してください。
argument-hint: "<file-path>"
compatibility: gh、curl、jq が必要です
---

# GitHub への添付ファイルのアップロード

## 背景

GitHub の Web UI でファイルをドラッグ&ドロップしたときと同じ保存先（user-attachments）へ、コマンドラインからアップロードします。
private リポジトリでは `raw.githubusercontent.com` の URL が画像として表示できないため、Issue や PR にスクリーンショットを貼るにはこの保存先を使う必要があります。

> [!NOTE]
> 公式ドキュメントに記載のないエンドポイントを使っているため、予告なく仕様が変わる可能性があります。

## 前提

- 対象リポジトリへの write 権限（アップロード用のトークンは write 権限を持つユーザーにしか発行されません）
- `gh` の認証（`repo` スコープ）

## 手順

### 1. アップロードする

```bash
bash ~/.agents/skills/personal-upload-attachment-to-github/scripts/upload.sh <file-path>
```

成功すると URL が出力されます。ファイルごとに 1 回ずつ実行してください。

カレントディレクトリの `git remote` とは別のリポジトリを対象にする場合は、第 2 引数に repository_id を渡します。

```bash
bash ~/.agents/skills/personal-upload-attachment-to-github/scripts/upload.sh <file-path> <repository_id>
```

### 2. 本文に貼る

出力された URL を、ファイルの種類に応じた記法で本文に埋め込みます。

| 種類   | 記法                                                             |
| :----- | :--------------------------------------------------------------- |
| 画像   | `![<代替テキスト>](<url>)`                                       |
| 動画   | URL を単体の行に置く（`![]()` で囲むと再生プレイヤーにならない） |
| その他 | `[<ファイル名>](<url>)`                                          |

## 注意点

> [!IMPORTANT]
> アップロードしたファイルを自分で削除する方法はありません（GitHub サポートへの依頼が必要です）。
> 意図しない情報が写り込んでいないか、アップロードする前にファイルの中身を確認してください。

> [!NOTE]
> URL はリポジトリの権限を継承します。アクセス権を持つ人がブラウザでログインしているときだけ表示され、未認証では 404 になります。
