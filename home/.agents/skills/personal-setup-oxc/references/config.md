# 設定ファイル

## 配置場所とファイル名

- oxlint: `.oxlintrc.json`（または `oxlint.config.ts`）。リント対象ファイルのディレクトリから上位に向かって探索し、最も近い設定ファイルが優先される。
- oxfmt: `.oxfmtrc.json` / `.oxfmtrc.jsonc`（または `oxfmt.config.ts`）。探索方法は oxlint と同様。

いずれも同一ディレクトリに JSON 系と TS 系の設定を共存させることはできない。モノレポでは、この探索の仕組みにより、ルートの設定に加えてパッケージ単位で上書きできる。プロジェクトの他の設定ファイルの形式に合わせ、特に理由がなければ `.json`（`.jsonc`）形式を使う。

## 除外設定

両ツールとも `.gitignore` を自動的に尊重するため、Git 管理外のファイルを個別に除外設定する必要はない。
Git 管理下だが対象から除外したいファイル（自動生成されたが差分を追うためコミットしているファイルなど）がある場合のみ、各設定ファイルの `ignorePatterns`（`.gitignore` 構文）に追記する。レガシーな `.oxlintignore` / `.prettierignore` 形式は新規には作らない。

## oxlint の主な設定項目

- `rules`: ルール個別の有効化と無効化、重大度
- `categories`: `correctness`、`suspicious`、`pedantic` などのカテゴリ単位の一括制御
- `plugins`: 有効化するネイティブプラグイン一覧。指定するとデフォルトセットを上書きするため、デフォルトのプラグインに追加したいだけの場合はデフォルトのプラグインも含めて明記する
- `overrides`: ファイルパターン別の設定上書き
- `env` / `globals`: 環境変数とグローバル変数の宣言

## oxfmt の主な設定項目

Prettier とほぼ互換（`printWidth`、`semi`、`singleQuote`、`trailingComma` など）。
oxfmt 独自の項目として `sortImports`（import 順序の自動整列）と `sortTailwindcss`（Tailwind CSS クラスの並び替え）があるが、移行元の Prettier 設定にはない項目のため、有効化するかどうかはユーザーに確認する。
