# dotfiles

## プロジェクト概要

P-Chan のポータブルな開発環境をコードで管理します。

## ディレクトリ構成

- `home/`: 設定ファイルの実体。`mise bootstrap` でホームディレクトリにシンボリックリンクされます。リンク対象は `home/.config/mise/config.toml` の `[dotfiles]` で定義します
  - `.agents/`: コーディングエージェント向けの共通 AGENTS.md と Agent Skills
- `.agents/skills/`: このリポジトリで作業するときに使う Agent Skills。`gh skill install <repo> <path> --agent universal --scope project` で取り込み、`gh skill update` で更新します。`.claude/skills` はここへのシンボリックリンクです
- `scripts/`: dotfiles の操作に使うスクリプト
- `bin/`: システム全体で使う自作コマンド
- `docs/apps/`: コードで管理できないアプリの手動設定の手順。README のアプリ一覧からリンクします

## 言語

- ドキュメントとコードのコメントは日本語で書きます
- コミットメッセージと PR のタイトル・本文は日本語で書きます。Conventional Commits の型とスコープは英語のままにします（例: `feat(zsh): 補完の設定を追加`）
- 外部から取り込んだスキル（`home/.agents/skills/.system/` など）は翻訳しません

## Git

- このリポジトリでは worktree を使いません。`home/` 以下のファイルはホームディレクトリからシンボリックリンクで参照される設定の実体なので、worktree で変更しても反映されません。代わりに、現在の作業ツリーでブランチを切り替えます
- `git clean -x` など、Git の管理対象外のファイルを削除するコマンドを実行しません。`~/.config/zsh` や `~/.ssh` などはディレクトリごとリンクしているので、シェルの履歴、`known_hosts`、マシン固有の mise の設定（`home/.config/mise/conf.d/`）など、復元できないマシン固有のファイルの実体がこのリポジトリ内にあります
- `home/.claude/settings.json` は Git のフィルタ（`.gitattributes` と `home/.config/git/filters/claude-settings.sh`）を通してコミットされます。コミット時にキーがソートされ、Herdr のフックのパスが `$HOME` 形式に置き換わるので、作業ツリーとインデックスの内容は一致しません。キーの順序は気にせず編集し、差分は `git diff` で確認します。背景は README の「Herdr の Claude 連携」を参照します

## 機密情報

このリポジトリは公開されていますが、変更のきっかけは他のリポジトリ（非公開のものを含む）で見つけた問題や得られた知見であることが多いです。それらのリポジトリの情報をこのリポジトリに含めないでください。問題は一般的な言葉で説明します。

## 検証

変更後は、CI と同じく次のコマンドが通ることを確認します。

- `pnpm check`: Prettier による整形の確認
- `pnpm test`: テスト
- `editorconfig-checker`: `.editorconfig` に沿っているかの確認。mise でグローバルにインストールされています

インストール手順（`scripts/install.sh` や `mise bootstrap`）を変更したときは、`zsh scripts/doctor.sh` で必要なコマンドがインストールされているかも確認します。
