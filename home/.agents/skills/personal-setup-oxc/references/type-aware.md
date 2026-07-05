# type-aware lint の有効化

## 前提

型情報を使ったルール（`await` し忘れた Promise、いわゆる floating promise の検出など）を有効化する。実行時は `oxlint-tsgolint`（tsgo ベース）が別プロセスとして型情報を解決するため、対象パッケージに解決可能な `tsconfig.json` が必要になる。

## 有効化するかどうかの判断

以下のいずれかに該当する場合は有効化を見送り、通常の（型情報を使わない）oxlint のみで運用する。判断に迷う場合はユーザーに確認する。モノレポの場合はパッケージごとにこの判断を行う。

- 対象パッケージが TypeScript の Project References（`references` フィールド）で他パッケージに依存しており、依存先をビルドしないと `.d.ts` が揃わない。ビルドを CI や開発フローに組み込む余地がない場合は無効化する
- `tsconfig.json` の `include` を絞り込めない（生成コードや大量の `.d.ts` を含むなど、構成上 `**/*` に近い範囲を含めざるを得ない）
- パッケージがほぼ JavaScript のみで、型情報から得られる恩恵が小さい

該当しなければ有効化する。

## 手順

1. `oxlint-tsgolint` を devDependencies としてインストールする。モノレポの場合はルートに1回だけインストールし、有効化するパッケージ間で共有する。
2. 恒常的に有効化する場合は設定ファイルに書く（CLI の `--type-aware` はその場限りの切り替え用）。
   ```json
   {
     "options": {
       "typeAware": true
     }
   }
   ```
   モノレポでパッケージごとに有効化するかどうかが異なる場合は、ルートの設定ファイルではなく、有効化するパッケージ自身の設定ファイルに書く（[config.md](config.md) の「最も近い設定ファイルが優先される」仕組みにより、そのパッケージ配下だけに適用される）。

## 注意

- `tsconfig.json` の `include` が `**/*` のように広すぎると、不要なファイルまで型解決の対象になり大幅に遅くなる。[personal-setup-typescript スキル](../../personal-setup-typescript/SKILL.md)で作成した tsconfig であれば、通常は適切な `include` になっている。
- モノレポで依存パッケージ側に型情報がない場合、あらかじめビルドして `.d.ts` を生成しておく必要がある（Project References を使っている場合は `tsgo -b` 相当のビルドを先に実行する）。
- tsgo（TypeScript 7 相当）との互換性が前提。プロジェクトの `tsconfig.json` に TypeScript 6.0 で非推奨になり 7.0 で削除されたオプションが残っている場合は、[personal-setup-typescript スキル](../../personal-setup-typescript/SKILL.md)側で対応する。
- 遅い場合は `OXC_LOG=debug oxlint --type-aware` でプログラムごとの処理時間を確認し、それでも改善しない場合は該当パッケージだけ無効化する。
