---
name: personal-detect-git-convention
description: 各リポジトリの既存の慣習からコミットメッセージ・PR タイトルの言語/スタイルを検出し、それに従うための手順をまとめたリファレンスです。ユーザーが Git の規約について尋ねたときや、他のスキルがコミット・PR 作成時に規約判定を必要とするときに使用してください。
allowed-tools: Bash(git config --local --get *), Bash(git config --local convention.language *), Bash(git config --local convention.commit-message-style *), Bash(git config --local convention.pull-request-title-style *), Bash(git config --local convention.branch-strategy *), Bash(git log:*), Bash(gh pr list *), Bash(gh issue list *), Bash(gh repo view *), Bash(gh api repos/*/branches/*/protection*), Bash(fd *), Read(*)
---

# Git 規約の検出

コミットメッセージ・PR タイトルについて、特定のスタイルを一律に強制するのではなく、対象リポジトリの `git log` や既存 PR から実際の慣習を検出し、それに従うための手順をまとめたリファレンスです。

## キャッシュキー一覧

| キー                                  | 意味                                      | 取りうる値                                                                                      |
| ------------------------------------- | ----------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `convention.language`                 | コミットメッセージ・PR タイトルなどの言語 | `ja` / `en` / `others:<説明>` / `others:?`                                                      |
| `convention.commit-message-style`     | コミットメッセージのスタイル              | `conventional-commits` / `gitmoji-unicode` / `gitmoji-shortcode` / `others:<説明>` / `others:?` |
| `convention.pull-request-title-style` | PR タイトルのスタイル                     | `conventional-commits` / `others:<説明>` / `others:?`                                           |
| `convention.branch-strategy`          | デフォルトブランチへの直接コミットの可否  | `direct-commit` / `pull-request` / `others:?`                                                   |

## 判定の共通手順

判定結果は `git config --local` を使ってリポジトリごとにキャッシュし、同じリポジトリでの再判定を避けます。

### 1. キャッシュ確認

判定したいキーについて、以下のコマンドでキャッシュを確認します。

```bash
git config --local --get convention.<key>
```

対象のキーがすべて設定済みの場合はその値を使い、判定をスキップします。

未設定のキーがある場合は、下記の各セクションで定義した情報源と基準を使って判定します。

### 2. キャッシュ保存

判定後、以下のコマンドで結果を保存します。

```bash
git config --local convention.<key> <判定結果>
```

判定結果が「その他」に該当する場合は、常に `others:` の形式で保存します。コロンの後ろは、検出した内容に一貫した法則があるかどうかで書き分けます。

| 状況                                     | 保存形式              |
| ---------------------------------------- | --------------------- |
| 独自だが一貫した法則を検出できた         | `others:<法則の説明>` |
| 特に一貫した法則が見られない（バラバラ） | `others:?`            |

一貫した法則がある場合は、次回キャッシュを読んだときに再度 `git log` などを調べ直さなくて済むよう、検出した内容を残します。

```bash
git config --local convention.commit-message-style "others:no-prefix, imperative mood"
```

一貫した法則が見られない場合、無理に説明を書いても意味がないため `?` を保存します。

```bash
git config --local convention.commit-message-style others:?
```

## 言語判定（`convention.language`）

以下の情報源を横断的に確認し、総合的に判定します。存在しない、または空の情報源は無視します。

| 情報源             | コマンド                                                                                                                             |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------ |
| README             | `fd -u -d 1 -i readme` で見つけたファイルを読む                                                                                      |
| コミットメッセージ | `git log --oneline -10 --perl-regexp --author='^((?!\[bot\]).)*$'`                                                                   |
| Issue              | `gh issue list --state all --limit 10 --json title --jq '[.[].title]'`                                                               |
| PR                 | `gh pr list --state all --limit 10 --json title,author --jq '[.[] \| select(.author.login \| test("\\[bot\\]$") \| not) \| .title]'` |

判定基準:

| 言語   | パターン           | 値                             |
| ------ | ------------------ | ------------------------------ |
| 日本語 | 日本語が含まれる   | `ja`                           |
| 英語   | 英語のみが含まれる | `en`                           |
| その他 | 上記以外           | `others:<言語名>` / `others:?` |

複数の情報源の判定結果が一致する場合は、その言語を採用します。

以下の場合は、無理に判定を確定させず、ユーザーに直接質問して言語を決定します。

- どの情報源からも言語を判断できる材料がなかった（README なし、コミット・Issue・PR もない、など）
- 情報源ごとに判定結果がバラバラで、優勢な言語が定まらない

## コミットメッセージスタイル判定（`convention.commit-message-style`）

`git log --oneline -10 --perl-regexp --author='^((?!\[bot\]).)*$'` を情報源とします。

| スタイル                  | パターン                | 値                                             |
| ------------------------- | ----------------------- | ---------------------------------------------- |
| Conventional Commits      | `feat:`, `fix:` 等      | `conventional-commits`                         |
| gitmoji（Unicode 絵文字） | Unicode 絵文字で始まる  | `gitmoji-unicode`                              |
| gitmoji（Shortcode）      | `:sparkles:` 等で始まる | `gitmoji-shortcode`                            |
| その他                    | 上記以外                | `others:<検出したスタイルの説明>` / `others:?` |

## PR タイトルスタイル判定（`convention.pull-request-title-style`）

`gh pr list --state all --limit 10 --json title,author --jq '[.[] | select(.author.login | test("\\[bot\\]$") | not) | .title]'` を情報源とします。

| スタイル             | パターン           | 値                                             |
| -------------------- | ------------------ | ---------------------------------------------- |
| Conventional Commits | `feat:`, `fix:` 等 | `conventional-commits`                         |
| その他               | 上記以外           | `others:<検出したスタイルの説明>` / `others:?` |

## ブランチ戦略判定（`convention.branch-strategy`）

デフォルトブランチのブランチ保護ルールの有無を情報源とします。

### 1. デフォルトブランチ名の取得

```bash
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name
```

### 2. ブランチ保護ルールの確認

```bash
gh api repos/{owner}/{repo}/branches/<デフォルトブランチ名>/protection
```

判定基準:

| レスポンス                                                    | 意味                                               | 値                         |
| ------------------------------------------------------------- | -------------------------------------------------- | -------------------------- |
| 200（保護ルールあり）                                         | デフォルトブランチへの直接コミットが制限されている | `pull-request`             |
| 404（保護ルールなし）                                         | デフォルトブランチへの直接コミットが許容されている | `direct-commit`            |
| 上記以外（GitHub 以外のホスティング、権限不足、通信エラー等） | 自動判定不可                                       | ユーザーに直接質問して決定 |
