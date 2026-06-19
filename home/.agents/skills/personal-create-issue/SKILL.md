---
name: personal-create-issue
description: ユーザーの説明から新しい GitHub Issue を作成します。ユーザーが Issue を「作って」「起票して」「立てて」「登録して」などと依頼したときに使用してください。
compatibility: Claude Code
allowed-tools: Bash(fd *), Bash(gh repo view *), Bash(gh issue list *), Bash(gh label list *), Bash(gh issue create *), Bash(git config --local --get *), Bash(git config --local convention.language *)
---

# personal-create-issue

## 目的

ユーザーの説明から、新しい GitHub Issue を作成する。

このスキルは、ユーザーのラフな依頼、バグ報告、機能追加案、改善案を、対象リポジトリの既存 Issue 運用にできるだけ沿った形で構造化する。

ユーザーが GitHub Issue を「作って」「起票して」「立てて」「登録して」「file して」などと依頼したときに使う。

## スコープ

このスキルがやること:

- 新しい GitHub Issue を作成する
- ユーザーの説明から Issue 種別を推定する
- リポジトリローカルの Issue テンプレートを優先する
- 分かりやすいタイトルと本文を生成する
- 不明点を勝手に断定せず、明示的に残す
- 適切な既存ラベルがあれば付与する

このスキルがやらないこと:

- 既存 Issue の編集・整理
- 古い Issue の一括修正
- Issue テンプレート自体の作成・変更
- 大量の新規ラベル作成
- リポジトリローカルの規約を無視したグローバルテンプレートの強制

## 基本方針

リポジトリローカルの規約を、このスキルのデフォルトより優先する。

`docs/issue-authoring.md` のような独自ドキュメントが存在することを前提にしない。

GitHub における Issue テンプレートの標準的な場所は以下である。

```txt
.github/ISSUE_TEMPLATE/
```

このスキル内の `templates/` は fallback 用であり、リポジトリに適切な Issue テンプレートがない場合にのみ使う。

## リポジトリ確認順

Issue を作成する前に、対象リポジトリで以下を確認する。

1. `.github/ISSUE_TEMPLATE/*.yml`
2. `.github/ISSUE_TEMPLATE/*.yaml`
3. `.github/ISSUE_TEMPLATE/*.md`
4. `.github/ISSUE_TEMPLATE/config.yml`
5. 既存のリポジトリラベル
6. このスキルの fallback テンプレート `templates/`

もし `CONTRIBUTING.md`、`.github/CONTRIBUTING.md` などが存在し、簡単に確認できる場合は補助情報として参照してよい。

ただし、それらの存在を前提にしてはいけない。

## Issue 種別の分類

ユーザーの依頼を、内部的に以下のいずれかへ分類する。

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

リポジトリローカルのテンプレートが存在する場合、内部分類をもっとも近いテンプレートにマッピングする。

例:

```txt
Feature     -> feature_request.yml, feature.yml, enhancement.md
Improvement -> improvement.yml, enhancement.yml, task.md
Bug         -> bug_report.yml, bug.yml
```

完全に一致するテンプレートがない場合は、もっとも近い汎用テンプレートを使う。

使えるローカルテンプレートがない場合は、このスキルの fallback テンプレートを使う。

```txt
Feature     -> templates/feature.md
Improvement -> templates/improvement.md
Bug         -> templates/bug.md
```

リポジトリ側に独自の命名がある場合、GitHub 上で `Feature` / `Improvement` / `Bug` という名前を強制しない。

## 情報が少ない場合の扱い

ユーザーの入力が薄くても、不要に作成を止めない。

可能な限り Issue として成立する本文を作り、不足している情報は `未確認事項` に残す。

質問するのは、回答がないと Issue として成立しない場合だけにする。

質問する場合のルール:

- 最大3問まで
- Issue 作成に本当に必要な質問だけにする
- 細かい不明点は質問せず、`未確認事項` に残す

通常、以下のような情報は `未確認事項` に残してよい。

- 対象画面
- 権限モデル
- API の詳細な形
- テスト範囲
- UI 文言
- 詳細なエラー条件

## ユーザー入力の分解

ユーザーはテンプレート通りに情報を渡さなくてよい。

このスキルは、ユーザーの自然文を読み取り、適切なセクションに分解する。

例:

```txt
ユーザー一覧の検索が使いにくい。名前で探したいのにメールアドレスでしか検索できなくて、毎回時間がかかる。
```

この場合、fallback の Improvement テンプレートでは次のように分離する。

```md
## 現状

ユーザー一覧では、メールアドレスでしか検索できない。

## 課題

名前でユーザーを探したいケースで目的のユーザーを見つけにくく、検索に時間がかかる。
```

分からない情報を勝手に創作してはいけない。

自信を持って埋められないセクションは `未確認` と書くか、`未確認事項` に移す。

## タイトル方針

タイトルは簡潔で、何をする Issue か分かるものにする。

良い例:

```txt
請求書PDFをダウンロードできるようにする
ユーザー一覧を名前で検索できるようにする
下書き請求書の詳細画面で500エラーになる問題を修正する
```

避ける例:

```txt
請求書対応
検索改善
バグ修正
```

## 本文方針

本文は、別のエンジニアが読んでも以下を理解できる状態を目指す。

- 何を変えるのか
- なぜ必要なのか
- 今回やること
- 今回やらないこと
- 何を満たせば完了なのか
- 何が未確認なのか

ユーザーが日本語で依頼した場合、またはリポジトリの Issue が日本語中心の場合は日本語で書く。

リポジトリのテンプレートや既存 Issue が英語中心の場合は英語で書く。

## ラベル方針

既存のリポジトリラベルを優先する。

よくあるマッピング:

```txt
Feature     -> enhancement, feature, type:feature
Improvement -> enhancement, improvement, type:improvement
Bug         -> bug, type:bug
```

デフォルトでは新規ラベルを作成しない。

適切な既存ラベルがない場合は、ラベルなしで Issue を作成する。

ユーザーが明示的にラベル作成を依頼した場合のみ、必要最小限のラベルを作成する。

## Issue 作成手順

Issue 作成時は、以下の順で進める。

1. 対象リポジトリを確認する
2. Issue 種別を判定する
3. 最適なリポジトリローカルテンプレートを選ぶ
4. ローカルテンプレートがなければ fallback テンプレートを使う
5. タイトルと本文を生成する
6. 不明点を `未確認事項` に残す
7. 適切な既存ラベルがあれば付与する
8. GitHub Issue を作成する
9. Issue URL と簡単な要約を返す

ユーザーが Issue 作成を明示的に依頼しており、作成権限がある場合は、単なる下書きだけを返さず実際に Issue を作成する。

作成権限がない場合は、作成予定のタイトルと本文を明確に提示する。

## Fallback テンプレート

Fallback テンプレートはこのファイルと同階層の `templates/` に置く。

```txt
templates/feature.md
templates/improvement.md
templates/bug.md
```

これらは、リポジトリに適切な Issue テンプレートが存在しない場合にのみ使う。
