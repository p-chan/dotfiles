# 既存のリンターとフォーマッターからの移行

## ESLint からの移行

1. ESLint の設定形式を確認する。
   - Flat Config（`eslint.config.js`/`.mjs`/`.ts` など、ESLint v9/v10）の場合はそのまま次に進む。
   - レガシー設定（`.eslintrc.*`）の場合、`@oxlint/migrate` は非対応のため、先に公式ツールで Flat Config に変換する。
     ```bash
     npx @eslint/migrate-config .eslintrc.json
     ```
2. `@oxlint/migrate` で ESLint 設定を oxlint 設定に変換する。
   ```bash
   npx @oxlint/migrate eslint.config.js
   ```
   ネイティブ対応していないルールやプラグインは、`.oxlintrc.json` の `jsPlugins` として自動的に引き継がれる（この場合も ESLint 本体は不要になる）。
3. 変換結果を確認し、方針を決める。
   - ほぼすべてのルールが移行できた場合: ESLint 本体と関連パッケージ（`eslint`、使用していた `eslint-plugin-*`／`eslint-config-*` など）、`.eslintrc.*`、`eslint.config.*` を削除する。`package.json` にレガシーな `eslintConfig` フィールドが残っている場合はそれも削除する。
   - `jsPlugins` でも移行できないプラグインがあり ESLint を残す必要がある場合: `eslint-plugin-oxlint` を導入し、oxlint が既にカバーしているルールを ESLint 側で無効化して二重に警告が出ないようにする。ESLint を残すかどうか、残す場合にどのルールのために残すかはユーザーに確認する。
     ```bash
     npm install --save-dev eslint-plugin-oxlint
     ```
     ESLint を残す場合、[SKILL.md](../SKILL.md) 手順6で置き換えた `lint` スクリプトはもう ESLint を実行しないため、`lint:eslint` などの専用スクリプトを別途追加し、`lint` から呼び出すか CI 側に呼び出しステップを追加して、ESLint のチェックが実行から漏れないようにする。

## Prettier からの移行

1. `oxfmt --migrate=prettier` で Prettier の設定を oxfmt 設定に変換する。
   ```bash
   npx oxfmt --migrate=prettier
   ```
2. `.prettierignore` があれば、内容を oxfmt 設定ファイルの `ignorePatterns` に統合する（詳細は [config.md](config.md)）。
3. Prettier 本体と関連パッケージ（`prettier`、`eslint-plugin-prettier` など）を削除する。ESLint を並行運用しており、フォーマット関連ルールとの競合回避のために `eslint-config-prettier` が必要な場合はそのまま残す。
   設定ファイル（`.prettierrc`、`.prettierrc.{json,yaml,yml,js,cjs,mjs}`、`prettier.config.{js,cjs,mjs}`）と `package.json` の `prettier` フィールドも、手順1で変換済みであれば削除する。
4. コードベース中の `// prettier-ignore` コメントを `// oxfmt-ignore` に置き換える（JS/TS ファイルのみ対応）。
5. oxfmt のデフォルト `printWidth` は 100（Prettier のデフォルトは 80）。この差などにより大きな整形差分が出ることがあるため、その場合は整形専用コミットを1つに分離し、`.git-blame-ignore-revs` への記録をユーザーに提案する。

## Biome からの移行

oxlint と oxfmt には Biome 設定を自動変換するツールは用意されていない。
`biome.json`（または `biome.jsonc`）のリントルールとフォーマットオプションの内容を確認し、[config.md](config.md) に従って oxlint と oxfmt の設定に手動で移植する。移植後、Biome 本体（`@biomejs/biome`）と `biome.json`／`biome.jsonc` を削除する。

## 共通: 移行後の消し残しチェック

どのツールから移行した場合も、以下に旧ツール（ESLint／Prettier／Biome）への言及が残っていないか確認し、残っていれば oxlint と oxfmt を使うよう更新または削除する。

- [ci.md](ci.md) に従って更新する CI ワークフロー
- [editor.md](editor.md) に従って更新するエディタの拡張機能と設定
- `package.json` の `lint` と `format` 以外のスクリプト（`check`、`format:write` など、旧ツールを直接呼び出しているもの）

## モノレポの場合

ESLint の設定は Flat Config とレガシー設定のいずれもパッケージごとに存在しうる。特にレガシー設定（`.eslintrc.*`）はディレクトリ単位でカスケードするため、ルートの設定ファイルだけでなく各パッケージの設定ファイルも確認し、存在する場合はパッケージごとに上記の変換手順を繰り返す。Prettier や Biome も設定ファイルがパッケージ単位で分かれている場合は同様に扱う。

移行結果を踏まえた方針決定（ESLint を削除するか、`eslint-plugin-oxlint` を使って残すか）もパッケージごとに判断してよい。oxlint と oxfmt はルートから実行してもディレクトリごとに最も近い設定ファイルを適用するため（[config.md](config.md)）、パッケージによって方針が異なっていてもルートの `lint`／`format:check` 実行は1本のままでよい。
ただし ESLint を残すパッケージがある場合、上記「ESLint からの移行」の手順3で追加する `lint:eslint` 相当のスクリプトは、そのパッケージの `package.json` に追加し、ルートの集約実行または CI から呼び出す。
