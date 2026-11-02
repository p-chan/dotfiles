---
name: migrate
description: git pull で増えたマイグレーションをこのマシンに適用します。dotfiles を git pull したあとに、やることの確認や反映を求められたときに使用してください。
---

# マイグレーションを適用する

直前の `git pull` で増えたエントリは、次のコマンドで確認します。

```sh
git diff ORIG_HEAD HEAD -- MIGRATIONS.md
```

`ORIG_HEAD` は直前の pull しか指さず、変更のない pull や `git reset` でも変わります。差分が空のときや、複数回 pull したときは、`MIGRATIONS.md` の日付を見て、どこまで適用したかをユーザーに確認します。

対象のプロファイルは `~/.config/mise/conf.d/profile-*.toml` で判断します。

対象のエントリの手順と副作用を示し、適用するものをユーザーに確認します。エントリは書いた時点の記録なので、現在のリポジトリの状態と合わないものや、適用済みと思われるものは、その理由も示します。古い順に実行し、失敗したらそこで止めて報告します。
