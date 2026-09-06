---
name: personal-request-review-to-copilot
description: GitHub Copilot に PR のレビューを依頼し、レビューが投稿されるまで待って指摘内容を報告します。ユーザーが GitHub Copilot にレビューの依頼を求めたときや、エージェントが GitHub Copilot にレビューを依頼するときに使用してください。
compatibility: gh、jq が必要です
---

# GitHub Copilot にレビューを依頼する

## ワークフロー

### 1. レビューを依頼する

```bash
gh pr edit --add-reviewer @copilot
```

### 2. レビューの投稿を待つ

`run_in_background` で実行してください。数分かかるため、待っている間はユーザーが別の作業を進められるようにし、スクリプトの終了通知を受けて手順 3 に進みます。

```bash
bash ~/.agents/skills/personal-request-review-to-copilot/scripts/wait-for-review.sh
```

対象の PR を明示する場合は `--pr` を渡します。省略した場合は現在のブランチの PR を対象にします。

```bash
bash ~/.agents/skills/personal-request-review-to-copilot/scripts/wait-for-review.sh --pr 123
```

最終行に結果を出力します。

| 出力            | 意味                                       | 次の対応                             |
| :-------------- | :----------------------------------------- | :----------------------------------- |
| `REVIEWED`      | レビューが投稿された                       | 手順 3 に進む                        |
| `NOT_REQUESTED` | Copilot へのレビュー依頼が無い             | 手順 1 を実行してから再実行する      |
| `TIMEOUT`       | 制限時間内にレビューが投稿されなかった     | ユーザーに報告し、待ち直すか確認する |
| `ERROR`         | API の取得に失敗したまま制限時間が経過した | ユーザーに報告する                   |

### 3. レビュー内容を取得する

最新の Copilot のレビュー本文を取得します。

```bash
gh api "repos/{owner}/{repo}/pulls/<PR番号>/reviews?per_page=100" --paginate \
  --jq '.[] | select(.user.login == "copilot-pull-request-reviewer[bot]") | {id, submitted_at, body}' \
  | jq -s 'max_by(.submitted_at)'
```

インラインコメントも取得します。`<レビューid>` には上で得た `id` を入れます。

```bash
gh api "repos/{owner}/{repo}/pulls/<PR番号>/comments?per_page=100" --paginate \
  --jq '.[] | select(.user.login == "Copilot" and .pull_request_review_id == <レビューid>) | {path, line: (.line // .original_line), body}'
```

### 4. 指摘を要約して報告する

指摘ごとに、内容と対象箇所（ファイル・行）を要約して報告してください。指摘が 0 件ならその旨を報告します。

> [!IMPORTANT]
> 対応するかどうかの判断はユーザーに委ねてください。妥当性についての見解を求められた場合は、該当コードを読んで評価したうえで答えます。

修正する方針が決まった場合、レビューコメントへの返信は [personal-use-gh-review-comment](../personal-use-gh-review-comment/SKILL.md) スキルに従ってください。
