# strictest 系ベースの追加

選定したベースには、最も厳格な型チェックを行うベース（**strictest 系**）をもう1つ重ねる。
[@tsconfig/bases](https://github.com/tsconfig/bases) の一覧から該当するパッケージ（例: `@tsconfig/strictest`）を探し、devDependencies としてインストールする。
最終的に各 tsconfig ファイルが `extends` するのは、選定したベースとこの strictest 系ベースの2つになる。

既存プロジェクトへの導入で、strictest 系を重ねるのが適さない場合の扱いは [existing-project.md](existing-project.md) を参照。
