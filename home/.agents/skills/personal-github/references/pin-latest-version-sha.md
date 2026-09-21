# 最新バージョンを SHA で固定する

アクションを追加するときは、セキュリティや安定性・互換性の観点から、最新バージョンを指定します。 また、タグの書き換えによるサプライチェーン攻撃を防ぐため SHA で固定します。

## 方法

**最新バージョンを特定する**

```sh
gh release list -R actions/checkout --json tagName,isLatest --jq '.[] | select(.isLatest) | .tagName'
```

**最新バージョンを指定する**

```yaml
- uses: actions/checkout@v6.0.2
```

**SHA で固定する**

[pinact](https://github.com/suzuki-shunsuke/pinact) を使って、タグ指定を SHA とタグコメントの形式に変換します。

```sh
pinact run
```

```yaml
- uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
```

## 例

```yaml
# 間違い
- uses: actions/checkout@main
- uses: actions/checkout@v4
- uses: actions/checkout@v6.0.2

# 正しい
- uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
```
