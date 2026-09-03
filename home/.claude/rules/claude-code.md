# Claude Code

- ユーザーに質問するときは、積極的に `AskUserQuestion` ツールを使います
- `rg` には検索対象のファイルやディレクトリを明示し、パス無しや `.` でカレントディレクトリ全体を検索しません。パイプの後ろで標準入力をフィルタするときは `rg` ではなく `grep` を使います
  - Claude Code 2.1.259 で、パス無しの `rg` がカレントディレクトリ全体の検索と判定され、`Read()` の deny ルールに触れて確認プロンプトが出るリグレッションの回避策です（[anthropics/claude-code#91751](https://github.com/anthropics/claude-code/issues/91751)）。修正されたらこの項目は削除します
