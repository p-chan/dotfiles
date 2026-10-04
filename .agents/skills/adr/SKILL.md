---
description: MADR 4.0に基づき、重要な意思決定をADRとして記録する。ADRの作成要否の判断、新規作成、既存ADRの置換時に使う。
metadata:
    github-path: skills/adr
    github-ref: refs/heads/main
    github-repo: https://github.com/p-chan/skills
    github-tree-sha: d6d82dbec62677edc0316173723978ad7cbf5e7f
name: adr
---
# ADR

新規作成前に `docs/decisions/` の関連ADRを確認する。

## 作成する条件

次のいずれかに当てはまり、判断理由をコードから十分に読み取れない場合に作成する。

- 後から変更するのが難しい、または高コスト
- 今回の変更を超えて将来の作業を制約する
- 共通の規約、契約、境界、方針、依存関係を新設・変更する

局所的・容易に戻せる・一時的・自明な実装判断には作成しない。複数案やトレードオフがあるだけでも作成しない。

## 作成

`docs/decisions/NNNN-kebab-case-title.md` に、既存最大番号 + 1（なければ `0001`）で作成する。

次のテンプレートを使う。

```markdown
# <決定内容が分かるタイトル>

## 背景と課題

## 検討した選択肢

## 決定

### 影響
```

実際に検討した選択肢だけを書き、理由と結果は簡潔に残す。

## 置換

既存の決定を変更する場合は過去ADRを書き換えず、新しいADRを作る。既存慣例がなければ旧ADRに `Superseded by`、新ADRに `Supersedes` を相互リンクで追加する。
