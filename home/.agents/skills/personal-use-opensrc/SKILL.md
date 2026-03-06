---
name: personal-use-opensrc
description: opensrc を利用して npm パッケージや GitHub リポジトリのコードを取得して確認します。 ユーザーが npm パッケージや GitHub リポジトリのコードの確認を求めたときや、エージェントが他の npm パッケージや GitHub リポジトリのコードを参照したほうがいいと判断したときに使います。
---

# [opensrc](https://github.com/vercel-labs/opensrc) を利用する

## 新しく取得する

新しく取得するときは、以下のコマンドを実行します。

```sh
# npm package (e.g., `opensrc 2ch-trip`)
opensrc <package>

# GitHub repository (e.g., `opensrc p-chan/dotfiles`)
opensrc <owner>/<repo>
```

取得したコードは、リポジトリルートの `opensrc` ディレクトリに保存されます。

> [!WARNING]
> 初回実行時はファイルの変更の許可を求めるプロンプトが表示されます。
> その場合は、一度コマンドの実行を中止して、`--modify=false` オプションを付けて、再度コマンドを実行します。
>
> ```sh
> opensrc --modify=false <package>
> opensrc --modify=false <owner>/<repo>
> ```

## 取得した npm パッケージや GitHub リポジトリの一覧を確認する

一覧を確認するときは、以下のコマンドを実行します。

```sh
opensrc list
```

## その他

その他、詳細は `opensrc -h` で確認できます。
