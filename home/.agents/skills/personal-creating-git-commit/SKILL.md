---
name: personal-creating-git-commit
description: Git リポジトリのスタイルに合わせてコミットを作成します。ユーザーがコミットを求めたときや、エージェントがコミットするときに必ず使用してください。
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git config:*), Bash(sed:*), Bash(tr:*), Bash(sort:*), Bash(xargs:*)
---

# Git コミット作成

## 前提

### アトミックコミット

1つのコミットは1つの独立した論理的変更のみを含めます。

複数の論理的変更が混在している場合は、変更ごとに分割してコミットします。

## ワークフロー

### 1. 情報収集

ステージングされた変更がある場合：

```bash
git diff --staged
```

ステージングされた変更がない場合：

```bash
git diff
```

### 2. 判定

#### キャッシュ確認

まず以下のコマンドでキャッシュを確認します：

```bash
git config --local --get commit-message.language 2>/dev/null || true
git config --local --get commit-message.format 2>/dev/null || true
```

両方設定済みの場合はその値を使い、言語判定とスタイル判定をスキップします。

未設定の項目がある場合は `git log --oneline -100` を実行し、言語判定とスタイル判定を行います。

#### 言語判定

| 言語   | パターン           | `commit-message.language` の値 |
| ------ | ------------------ | ------------------------------ |
| 日本語 | 日本語が含まれる   | `ja`                           |
| 英語   | 英語のみが含まれる | `en`                           |
| その他 | 上記以外           | `others`                       |

#### スタイル判定

| スタイル                  | パターン                | `commit-message.format` の値 |
| ------------------------- | ----------------------- | ---------------------------- |
| Conventional Commits      | `feat:`, `fix:` 等      | `conventional-commits`       |
| gitmoji（Unicode 絵文字） | Unicode 絵文字で始まる  | `gitmoji-unicode`            |
| gitmoji（Shortcode）      | `:sparkles:` 等で始まる | `gitmoji-shortcode`          |
| その他                    | 上記以外                | `others`                     |

#### キャッシュ保存

判定結果をキャッシュに保存します。

```bash
git config --local commit-message.language <判定結果>
git config --local commit-message.format <判定結果>
```

#### スコープ判定

以下のコマンドでスコープ一覧を取得します。

```bash
git log --oneline -n 999 | sed -n 's/^[a-f0-9]* [^(:]*(\([^)]*\)):.*/\1/p' | tr ',' '\n' | sed 's/^ *//' | sort -u | xargs | sed 's/ /, /g'
```

出力が空の場合はスコープなしとして扱います。

### 3. コミットメッセージ生成

判定結果に基づいてコミットメッセージを生成します。

- **タイトル（1行目）**: What（何をしたか）を簡潔に、50 文字以内
- **ボディ（本文）**: Why（なぜしたか）を必要に応じて補足
- **コード参照**: コードやパスを表す場合はバッククォートで囲む
- **言語**: 判定した言語に合わせる
- **スタイル**: 判定したスタイルに従う（必ず判定したスタイルのリファレンスを参照する）
  - [Conventional Commits](references/conventional-commits.md)
  - [gitmoji](references/gitmoji.md)
- **スコープ**: スコープ一覧から適切なものを選択（該当する場合）

### 4. コミット作成

生成したメッセージを表示し、コミットを作成します。
