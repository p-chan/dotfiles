---
name: personal-commit
description: Git リポジトリのスタイルに合わせてコミットを作成します。ユーザーがコミットを求めたときや、エージェントがコミットするときに必ず使用してください。
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git config --local --get *), Bash(git config --local convention.branch-strategy *), Bash(sed:*), Bash(tr:*), Bash(sort:*), Bash(xargs:*), Bash(gh issue list *), Bash(gh pr list *), Bash(gh repo view *), Bash(gh api repos/*/branches/*/protection*), Bash(fd *), Read(*)
---

# Git コミット作成

## 前提

### アトミックコミット

1つのコミットは1つの独立した論理的変更のみを含めます。

複数の論理的変更が混在している場合は、変更ごとに分割してコミットします。

## ワークフロー

### 1. ブランチ確認

以下のコマンドで現在のブランチを確認します。

```bash
git branch --show-current
```

現在のブランチが `main` または `master` の場合、[personal-detect-git-convention スキル](../personal-detect-git-convention/SKILL.md)の手順に従い `convention.branch-strategy` を判定します。

- `pull-request` の場合: 新しいブランチを作成してから次のステップに進みます。
- `direct-commit` の場合: そのまま次のステップに進みます。

### 2. 情報収集

ステージングされた変更がある場合：

```bash
git diff --staged
```

ステージングされた変更がない場合：

```bash
git diff
```

### 3. 判定

[personal-detect-git-convention スキル](../personal-detect-git-convention/SKILL.md)の手順に従い、以下を判定します。

- 言語（`convention.language`）
- コミットメッセージスタイル（`convention.commit-message-style`）

#### スコープ判定

以下のコマンドでスコープ一覧を取得します。

```bash
git log --oneline -n 999 --perl-regexp --author='^((?!\[bot\]).)*$' | sed -n 's/^[a-f0-9]* [^(:]*(\([^)]*\)):.*/\1/p' | tr ',' '\n' | sed 's/^ *//' | sort -u | xargs | sed 's/ /, /g'
```

出力が空の場合はスコープなしとして扱います。

### 4. コミットメッセージ生成

判定結果に基づいてコミットメッセージを生成します。

- **タイトル（1行目）**: What（何をしたか）を簡潔に、50 文字以内
- **ボディ（本文）**: Why（なぜしたか）を必要に応じて補足
- **コード参照**: コードやパスを表す場合はバッククォートで囲む
- **言語**: 判定した言語に合わせる
- **スタイル**: 判定したスタイルに従う（必ず判定したスタイルのリファレンスを参照する）
  - [Conventional Commits](references/conventional-commits.md)
  - [gitmoji](references/gitmoji.md)
- **スコープ**: スコープ一覧から適切なものを選択（該当する場合）

### 5. コミット作成

生成したメッセージを表示し、コミットを作成します。
