# tsconfig ベースの選定

[@tsconfig/bases](https://github.com/tsconfig/bases) から、対象の tsconfig ファイルに最も適したベースを1つ選び、devDependencies としてインストールする。

選定したこのベースには、[strictest 系ベース](strictest-base.md)をもう1つ重ねる。

https://github.com/tsconfig/bases のリポジトリ（`bases/` ディレクトリまたは README）で、その時点の一覧を確認したうえで、以下の優先順で1つだけ選ぶ。
上から順に確認し、最初に条件を満たしたものを採用して残りは見ない。

1. **フレームワーク固有のベース**：`package.json` の dependencies / devDependencies からプロジェクトが使用しているフレームワークを特定する。一覧に対応する専用ベース（例: Next.js 向けなど）があれば、実行ランタイムが何であってもそれを使う。
2. **Node.js 以外のランタイム固有のベース**（1 に該当がない場合）：Node.js 以外のランタイム（Bun など）を使用しているか確認する。一覧に対応する専用ベースがあればそれを使う。
3. **Node.js のバージョン別ベース**（1, 2 のいずれにも該当しない場合、すなわちフレームワークがなくランタイムが Node.js の場合）：`package.json` の `engines.node`、`.node-version`、`.nvmrc`、`mise.toml` / `.mise.toml` の `[tools]` セクションの `node` の優先順でプロジェクトの Node.js バージョンを特定する。メジャーバージョンが特定でき、かつ該当バージョンの Node.js 向けベースが一覧に存在すればそれを使う。特定できない場合、または存在しない場合は Node.js LTS 向けのベースを使う。
4. **汎用的なベース**（1〜3 のいずれにも該当しない場合）：一覧の中から、フレームワークやランタイムに依存しない汎用的なベースを使う。

モノレポの場合、選定するベースはパッケージごとに異なりうる（例: フロントエンドアプリと Node.js バックエンドが同居する場合）。該当パッケージの `package.json` に devDependencies としてインストールする。
