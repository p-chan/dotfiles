# Issue の関係性を設定する

Issue が他の Issue と関係しているときは、本文に書くだけでなく GitHub の Relationships として設定する。Relationships は Issue のサイドバーやプロジェクトに表示され、進捗の集計や絞り込みにも使われるので、本文のリンクより関係が伝わりやすい。

## 関係の種類

関係の性質にもっとも近いものを 1 つ選ぶ。

| 種類       | 使う場面                                               | 例                                             |
| ---------- | ------------------------------------------------------ | ---------------------------------------------- |
| 親子       | 大きな Issue を作業単位に分割したとき                  | 「検索機能を刷新する」の下に個々の改修を置く   |
| 依存       | 一方が完了しないと、もう一方に着手・完了できないとき   | API の追加が終わるまで画面の実装を始められない |
| 単純な関連 | 親子でも依存でもないが、あわせて読むと理解が深まるとき | 同じ箇所で起きている別のバグ                   |

親子と依存の両方に当てはまるときは、親子を選ぶ。

## 設定方法

`gh` のフラグで設定できる関係は、`gh` で設定する。フラグは `gh issue create --help` や `gh issue edit --help` で確認する。

フラグがない関係は、GraphQL API で設定する。たとえば、単純な関連は `addRelatesTo` で設定する。

```bash
issue_id=$(gh issue view <number> --json id --jq .id)
related_id=$(gh issue view <related-number> --json id --jq .id)

gh api graphql \
  -f query='mutation($issueId: ID!, $relatedIssueId: ID!) { addRelatesTo(input: {issueId: $issueId, relatedIssueId: $relatedIssueId}) { clientMutationId } }' \
  -f issueId="$issue_id" \
  -f relatedIssueId="$related_id"
```

## 設定済みの関係を確認する

`gh issue view --help` の JSON FIELDS にある関係は、`gh issue view <number> --json <fields>` で確認する。ない関係は、GraphQL API で確認する。たとえば、単純な関連は `relatesTo` で確認する。

```bash
gh api graphql \
  -f query='query($owner: String!, $repo: String!, $number: Int!) { repository(owner: $owner, name: $repo) { issue(number: $number) { relatesTo(first: 50) { nodes { number title url } } } } }' \
  -f owner=<owner> -f repo=<repo> -F number=<number>
```

## 注意点

- ユーザーの説明、Issue の本文、コードベースなどから関係が確かだといえるときは、そのまま設定する。確信が持てないときは、ユーザーに確認してから設定する
- 本文には、関係の理由など Relationships だけでは伝わらない情報を書く
