# dotfiles

## プロジェクト概要

P-Chan のポータブルな開発環境をコードで管理します。

## ディレクトリ構成

- `home/`: 主要な設定ファイル。`mise bootstrap` でホームディレクトリにシンボリックリンクされます（`home/.config/mise/config.toml` の `[dotfiles]` を参照）
  - `.config/`:
    - `zsh/`
    - `tmux/`
    - `vim/`
    - `git/`
    - `ghostty/`
    - `mise/`
    - `gh/`
    - `homebrew/`: 共通とプロファイル別の `Brewfile`
    - `karabiner/`
    - `sheldon/`
    - `zsh-abbr/`
    - `fixpack/`
    - `starship.toml`
  - `.agents/`: コーディングエージェント向けの共通 AGENTS.md と Agent Skills
  - `.claude/`
  - `.codex/`
  - `.ssh/`
  - `.zshenv`
  - `.editorconfig`
- `scripts/`: dotfiles の操作に使うスクリプト
- `bin/`: システム全体で使う自作コマンド

## 技術スタック

- シェルスクリプト
- Node.js

## 言語

- ドキュメントとコードのコメントは日本語で書きます
- コミットメッセージと PR のタイトル・本文は日本語で書きます。Conventional Commits の型とスコープは英語のままにします（例: `feat(zsh): 補完の設定を追加`）
- 外部から取り込んだスキル（`home/.agents/skills/.system/` など）は翻訳しません

## Git

- このリポジトリでは worktree を使いません。`home/` 以下のファイルはホームディレクトリからシンボリックリンクで参照される設定の実体なので、worktree で変更しても反映されません。代わりに、現在の作業ツリーでブランチを切り替えます

## 機密情報

このリポジトリは公開されていますが、変更のきっかけは他のリポジトリ（非公開のものを含む）で見つけた問題や得られた知見であることが多いです。それらのリポジトリの情報をこのリポジトリに含めないでください。問題は一般的な言葉で説明します。

## 検証

- `scripts/doctor.sh`: 必要なコマンドがインストールされているか確認します
