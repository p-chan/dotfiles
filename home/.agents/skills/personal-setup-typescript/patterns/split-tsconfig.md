# 複数 tsconfig パターン（Project References で分割）

実行環境の数だけサブ設定ファイルを作り、TypeScript の Project References で束ねる場合の手順。

## 1. サブ設定ファイルの構成を決める

実行環境の数だけサブ設定ファイルを作る。ルートの `tsconfig.json` には `"files": []` と、各サブ設定ファイルへの `"references"` だけを持たせる。
サブ設定ファイルの名前や数はプロジェクトの実行環境の分け方次第であり、決まった正解はない（例: Vite の公式テンプレートは `tsconfig.app.json` と `tsconfig.node.json` の2つに分けている）。

```json
// tsconfig.json
{
  "files": [],
  "references": [
    { "path": "./tsconfig.app.json" },
    { "path": "./tsconfig.node.json" }
  ]
}
```

## 2. サブ設定ファイルごとに以下を行う

### 2-1. tsconfig ベースの選定とインストール

[references/tsconfig-base-selection.md](../references/tsconfig-base-selection.md) に従う。
実行環境が Node.js であることが確定しているサブ設定ファイル（ビルドツールの設定ファイル用など）については、優先順のうち 3 から確認してよい。

### 2-2. strictest 系ベースの追加

[references/strictest-base.md](../references/strictest-base.md) に従う。

### 2-3. @types/node のインストール

[references/types-node.md](../references/types-node.md) に従って判断する。

### 2-4. サブ設定ファイルの作成と更新

[references/existing-project.md](../references/existing-project.md) の内容を踏まえて作成または更新する。
`noEmit: true` は必ず設定する（この後の手順3でビルドモード `tsgo -b` を使うために必須）。

以下は、Vite の react-ts テンプレートに倣い src とビルドツール設定の2環境に分割する例である。

```json
// tsconfig.app.json
{
  "compilerOptions": {
    "noEmit": true
  },
  "extends": [
    "@tsconfig/<選定したベース>/tsconfig.json",
    "@tsconfig/<strictest 系ベース>/tsconfig.json"
  ],
  "include": ["src"]
}
```

`types` を明示しない場合、TypeScript は `node_modules/@types` 配下の全パッケージを自動で読み込む。
選定したベースが `types` を自前で制限していない場合（`@tsconfig/vite-react` の `"types": ["vite/client"]` のように制限しているベースもある）、他のサブ設定ファイルのために `@types/node` をインストールすると、ブラウザ向けのこの設定にも Node.js のグローバル型が意図せず混入する。
その場合はこの設定側にも `types` を明示し、必要なもの（ブラウザ向けのアンビエント型など）だけに絞る。

```json
// tsconfig.node.json
{
  "compilerOptions": {
    "noEmit": true,
    "types": ["node"]
  },
  "extends": [
    "@tsconfig/<選定したベース>/tsconfig.json",
    "@tsconfig/<strictest 系ベース>/tsconfig.json"
  ],
  "include": ["vite.config.ts"]
}
```

## 3. package.json への typecheck スクリプト追加

ルートの `tsconfig.json` を対象にビルドモード（`-b`）で実行する。`tsgo` は Project References によるビルドモードに対応している。
既に `tsc -b` などの同等スクリプトがある場合は置き換える。

```json
{
  "scripts": {
    "typecheck": "tsgo -b"
  }
}
```

## モノレポの場合

[references/monorepo.md](../references/monorepo.md) を参照し、上記1〜3をパッケージごとに適用したうえでルートの集約スクリプトを追加する。
