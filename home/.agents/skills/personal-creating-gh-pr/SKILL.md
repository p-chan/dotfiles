---
name: personal-creating-gh-pr
description: GitHub の PR を作成します。ユーザーが PR の作成を求めたときや、エージェントが PR を作成するときに使用してください。
compatibility: Claude Code
allowed-tools: Bash(git config *), Bash(gh pr list *), Bash(git ls-remote *)
---

# GitHub PR 作成

## ワークフロー

### 1. 判定

#### キャッシュ確認

まず以下のコマンドでキャッシュを確認します：

```bash
git config --local --get convention.language 2>/dev/null || true
git config --local --get convention.pull-request-title 2>/dev/null || true
```

両方設定済みの場合はその値を使い、言語判定とスタイル判定をスキップします。

未設定の項目がある場合は、以下のコマンドを実行し、言語判定とスタイル判定を行います。

```sh
gh pr list --state all --limit 10 --json title,author --jq '[.[] | select(.author.login | test("\\[bot\\]$") | not) | .title]'
```

#### 言語判定

| 言語   | パターン           | `convention.language` の値 |
| ------ | ------------------ | --------------- |
| 日本語 | 日本語が含まれる   | `ja`            |
| 英語   | 英語のみが含まれる | `en`            |
| その他 | 上記以外           | `others`        |

#### スタイル判定

| スタイル             | パターン           | `convention.pull-request-title` の値 |
| -------------------- | ------------------ | -------------------------------- |
| Conventional Commits | `feat:`, `fix:` 等 | `conventional-commits`           |
| その他               | 上記以外           | `others`                         |

#### キャッシュ保存

判定結果をキャッシュに保存します。

```bash
git config --local convention.language <判定結果>
git config --local convention.pull-request-title <判定結果>
```

### 2. テンプレート確認

以下のファイルが存在する場合は、内容を確認します。

- `.github/pull_request_template.md`
- `.github/PULL_REQUEST_TEMPLATE/*.md`

### 3. プッシュ

現在のブランチがリモートにプッシュ済みか確認します。

```sh
git ls-remote --heads origin <branch-name>
```

出力が空の場合はプッシュします。

```sh
git push -u origin <branch-name>
```

### 4. タイトルと本文の生成

最初に判定した言語とスタイル、その次に確認したテンプレートに基づいて、タイトルと本文を生成します。

テンプレートが存在しない場合は、以下のテンプレートを利用してください。

```md
## Why

## What

## Notes
```

### 5. 作成

```sh
gh pr create \
  --assignee @me \
  --body "$body" \
  --title "$title"
```

コンテキストに応じて、他のオプションも追加できます。
