# @types/node のインストール判断

対象の tsconfig ファイルが Node.js の API（`process`、`Buffer`、`fs` など）に触れる場合、`@types/node` を devDependencies としてインストールし、その tsconfig ファイルの `compilerOptions.types` に `"node"` を追加する。
どのベースを選んだかではなく、実際にそのファイルが Node.js 上で動くかどうかで判断する。

TypeScript 7 では `types` の既定値が `[]` になり、`node_modules/@types` 配下のパッケージは自動読み込みされなくなった（TypeScript 6 以前は自動で全パッケージを読み込んでいた）。そのため `@types/node` のインストールだけでは不十分で、`compilerOptions.types` への明示的な追加が必須になる。

- `@tsconfig/bases` の Node.js バージョン別ベースや Node.js LTS 向けベースは `lib` や `module` などは設定するが `types` は含まないため、必ずこのインストールと `types` への追加が必要になる。
- Next.js、Remix、Nuxt のように SSR やサーバー処理を伴うフレームワーク固有のベースも、Node.js 上で動く部分があるため通常は必要になる（例: 公式の `create-next-app` は TypeScript プロジェクトで常に `@types/node` を追加している）。ベースが `types` を自前で設定している場合は、その配列に `"node"` を追加する。
- ブラウザのみで完結するクライアントサイド専用の設定（例: Vite の `tsconfig.app.json` に相当する部分）には不要。
- Bun など Node.js 以外のランタイム向けのベースを使う tsconfig ファイルには不要（それぞれ独自のグローバル型を持つ）。

モノレポの場合は該当パッケージの `package.json` にインストールする。
