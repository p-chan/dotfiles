---
name: personal-clarify-issue
description: 既存の GitHub Issue を整理・再構成します。ユーザーが Issue を「整理して」「構造化して」「書き直して」「わかりやすくして」「clarify して」などと依頼したときに使用してください。
compatibility: Claude Code
allowed-tools: Bash(fd *), Bash(gh repo view *), Bash(gh issue view *), Bash(gh issue edit *), Bash(gh issue list *), Bash(gh label list *), Bash(git config --local --get *), Bash(git config --local convention.language *)
---

# personal-clarify-issue

## 目的

既存の GitHub Issue を読み取り、内容を保持しながら構造・表現・明確さを改善する。

このスキルは、以下のような状態の Issue を整理する。

- 書き殴られた状態で構造がない
- 再現手順や完了条件が抜けている
- 「何をする Issue か」がタイトルだけでは分からない
- 複数の関心事が混在している

ユーザーが Issue を「整理して」「構造化して」「書き直して」「わかりやすくして」「clarify して」などと依頼したときに使う。

## スコープ

このスキルがやること:

- 既存 Issue の本文を構造化・再構成する
- 不明点を `未確認事項` として明示する
- タイトルが不明瞭な場合は改善案を提示し、ユーザーの確認を取ってから更新する
- GitHub Issue を実際に編集する

このスキルがやらないこと:

- 著者の意図・主張を変える
- 既存 Issue を削除・クローズする
- 新規 Issue を作成する
- ラベルを新規作成する
- 元の本文にない情報を勝手に追加する

## 基本方針

著者の意図を忠実に保ちながら、構造だけを改善する。

情報の解釈に迷ったときは「変更しない」を選ぶ。推測で内容を補ってはいけない。

リポジトリローカルの Issue テンプレートが存在する場合、そのセクション構成を参考にする。

## Issue 読み取り手順

1. `gh issue view <issue-number> --json number,title,body,labels,url` で Issue を取得する
2. Issue の種別を判定する（Feature / Improvement / Bug）
3. 適切なテンプレート構造を選ぶ
4. 現在の本文を各セクションにマッピングする

## Issue 種別の分類

現在の Issue 内容を読み取り、以下のいずれかへ分類する。

### Feature

新しい能力・機能・画面・API・振る舞いを追加する Issue。

典型的なシグナル:

- 「できるようにしたい」
- 「追加したい」
- 「対応したい」
- `add`
- `support`
- `implement`
- `new`

### Improvement

既存の機能、UX、性能、保守性、運用、分かりやすさを改善する Issue。

典型的なシグナル:

- 「使いにくい」
- 「遅い」
- 「分かりにくい」
- 「改善したい」
- `improve`
- `optimize`
- `refactor`

### Bug

壊れている、期待通りでない、誤っている、意図した挙動と違うものを修正する Issue。

典型的なシグナル:

- 「動かない」
- 「エラーになる」
- 「壊れている」
- 「期待と違う」
- `bug`
- `fix`
- `regression`

## テンプレート選択

リポジトリローカルのテンプレートが存在する場合、そのセクション構成を参考にする。

```txt
.github/ISSUE_TEMPLATE/
```

リポジトリにテンプレートがない場合は、このスキルの fallback テンプレートを使う。

```txt
Feature     -> templates/feature.md
Improvement -> templates/improvement.md
Bug         -> templates/bug.md
```

## 情報のマッピング方針

既存の本文から情報を抽出し、適切なセクションに移す。

- 元の本文にある情報: 適切なセクションへ移動する
- 元の本文にない情報: セクションを空欄にするか、`未確認` と書く
- 元の本文に複数セクションにまたがる情報: もっとも適切なセクションに配置し、残りを `未確認事項` に記載する

元の本文にない情報を勝手に創作してはいけない。

## タイトルの扱い

タイトルが以下の状態の場合は、改善案を提示してユーザーに確認を取る。

- 抽象的すぎる（例: 「バグ修正」「対応」「検討」）
- 動詞がなく Issue の目的が分からない
- 種別と内容が一致していない

ユーザーが確認した場合のみタイトルを更新する。

タイトルが十分に明確な場合は変更しない。

## 不明点の扱い

元の本文から読み取れない情報は `未確認事項` セクションに列挙する。

情報が少ない場合でも、分かる範囲で本文を構造化し、不足分を `未確認事項` に残す。

## Issue 編集手順

1. 対象 Issue を取得する
2. Issue 種別を判定する
3. テンプレートを選択する
4. 既存の本文を各セクションにマッピングする
5. 不明点を `未確認事項` に列挙する
6. タイトルが不明瞭な場合は改善案をユーザーに確認する
7. `gh issue edit <issue-number> --body <新しい本文>` で本文を更新する
8. タイトルも変更する場合は `--title <新しいタイトル>` を追加する
9. 更新後の Issue URL を返す

## Fallback テンプレート

Fallback テンプレートはこのファイルと同階層の `templates/` に置く。

```txt
templates/feature.md
templates/improvement.md
templates/bug.md
```

これらは、リポジトリに適切な Issue テンプレートが存在しない場合にのみ使う。
