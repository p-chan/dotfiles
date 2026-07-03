# モノレポの場合の追加考慮事項

## パッケージの検出

`package.json` の `workspaces` フィールドや `pnpm-workspace.yaml` などからパッケージ一覧を検出する。
パターンの各手順（tsconfig を分割するかの判断、ベース選定、`@types/node`、tsconfig の作成、`typecheck` スクリプトの追加）はパッケージごとに繰り返す。

## インストール先

- `typescript` と `tsgo` はルートに1回だけインストールし、全パッケージで共有する。
- `@tsconfig/<base>` と `@types/node` は該当パッケージの `package.json` にインストールする（パッケージごとにベースが異なりうるため）。

## パッケージ間の Project References は組まない

各パッケージの tsconfig 作成は独立して行う。
パッケージ間を TypeScript の Project References でまたいで束ねる（ルートに集約用の `tsconfig.json` を置く）ことはここでは行わない。
モノレポ全体の型チェックの実行方法は次項で扱う。

## ルートの集約スクリプト

各パッケージの `package.json` に `typecheck` スクリプトを追加した上で、モノレポ全体を1コマンドで型チェックできるよう、ルートの `package.json` にも集約用の `typecheck` スクリプトを追加する。

`turbo.json` や `nx.json` など既存のタスクランナー設定があり、他のスクリプト（`lint`、`test` など）がそれ経由で実行されている場合は、そのタスクランナーの流儀に合わせる。
存在しない場合は、検出したパッケージマネージャーのワークスペース横断実行機能を使う。

| パッケージマネージャー | ルートの `typecheck` スクリプト               |
| :--------------------- | :-------------------------------------------- |
| npm                    | `npm run typecheck --workspaces --if-present` |
| yarn (Berry)           | `yarn workspaces foreach -A run typecheck`    |
| pnpm                   | `pnpm run -r typecheck`                       |
| bun                    | `bun run --filter '*' typecheck`              |

## CI

CI ジョブでは、パッケージごとのスクリプトではなく、上記でルートに追加した集約用の `typecheck` スクリプトを実行する。
