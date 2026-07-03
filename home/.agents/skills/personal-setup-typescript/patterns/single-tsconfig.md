# 単一 tsconfig パターン

tsconfig を分割しない場合の手順。

## 1. tsconfig ベースの選定とインストール

[references/tsconfig-base-selection.md](../references/tsconfig-base-selection.md) に従い、プロジェクト全体を対象に1つのベースを選ぶ。

## 2. strictest 系ベースの追加

[references/strictest-base.md](../references/strictest-base.md) に従う。

## 3. @types/node のインストール

[references/types-node.md](../references/types-node.md) に従って判断する。

## 4. tsconfig.json の作成と更新

[references/existing-project.md](../references/existing-project.md) の内容を踏まえて作成または更新する。

```json
{
  "extends": ["@tsconfig/<選定したベース>/tsconfig.json", "@tsconfig/<strictest 系ベース>/tsconfig.json"],
  "include": ["src"]
}
```

## 5. package.json への typecheck スクリプト追加

`scripts` に以下を追加する。
既に `tsc --noEmit` などの同等スクリプトがある場合は置き換える。

```json
{
  "scripts": {
    "typecheck": "tsgo --noEmit"
  }
}
```

## モノレポの場合

[references/monorepo.md](../references/monorepo.md) を参照し、上記1〜5をパッケージごとに適用したうえでルートの集約スクリプトを追加する。
