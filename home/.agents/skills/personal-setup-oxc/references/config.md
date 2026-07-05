# 設定ファイル

## 配置場所とファイル名

- oxlint: `.oxlintrc.json`（または `oxlint.config.ts`）。リント対象ファイルのディレクトリから上位に向かって探索し、最も近い設定ファイルが優先される。
- oxfmt: `.oxfmtrc.json` / `.oxfmtrc.jsonc`（または `oxfmt.config.ts`）。探索方法は oxlint と同様。

いずれも同一ディレクトリに JSON 系と TS 系の設定を共存させることはできない。モノレポでは、この探索の仕組みにより、ルートの設定に加えてパッケージ単位で上書きできる。プロジェクトの他の設定ファイルの形式に合わせ、特に理由がなければ `.json`（`.jsonc`）形式を使う。

## 除外設定

両ツールとも `.gitignore` を自動的に尊重するため、Git 管理外のファイルを個別に除外設定する必要はない。
Git 管理下だが対象から除外したいファイル（自動生成されたが差分を追うためコミットしているファイルなど）がある場合のみ、各設定ファイルの `ignorePatterns`（`.gitignore` 構文）に追記する。レガシーな `.oxlintignore` / `.prettierignore` 形式は新規には作らない。

## 設定項目の詳細

個々の設定項目は頻繁に追加・変更されるため、このファイルには列挙しない。設定を書く際は都度、公式のリファレンスを確認する。

- oxlint: https://oxc.rs/docs/guide/usage/linter/config-file-reference.html
- oxfmt: https://oxc.rs/docs/guide/usage/formatter/config-file-reference.html

oxfmt には `sortImports`（import 順序の自動整列）や `sortTailwindcss`（Tailwind CSS クラスの並び替え）など、Prettier にはない項目がある。移行元の Prettier 設定には存在しない項目のため、有効化するかどうかはユーザーに確認する。
