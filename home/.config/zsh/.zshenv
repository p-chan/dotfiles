export EDITOR="vim"
export VISUAL="vim"
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"

typeset -U path fpath

# ~/.zshenv は <repo>/home 内のファイルへのシンボリックリンクで、mise の dotfiles の機能が dotfiles.root 設定をもとに管理している
# このリンクを解決すれば、シェルを起動するたびにプロセスを fork しなくてもリポジトリの場所がわかる（:A は zsh だけでシンボリックリンクを解決する）
# フォールバックは、初回のインストールが終わる前のシェルのためにある
if [[ -L "$HOME/.zshenv" ]]; then
  export DOTFILES_DIR="${${:-$HOME/.zshenv}:A:h:h}"
else
  export DOTFILES_DIR="$HOME/src/github.com/p-chan/dotfiles"
fi
export PATH="$HOME/.local/bin:$PATH"
# 対話的なシェルで activate したときも、アップデートに強いフォールバックとして、実際のツールの後ろに shim を残す
export PATH="$HOME/.local/share/mise/shims:$PATH"
export PATH="$DOTFILES_DIR/bin:$PATH"

# 対話的なシェルは .zshrc の `mise activate` を使う
# スクリプトでは環境をすぐに使える必要があり、`mise up` の前後で変わらない shim が必要
if [[ ! -o interactive ]] && type mise &>/dev/null; then
  eval "$(mise env -s zsh)"
  path=("$HOME/.local/share/mise/shims" "${path[@]}")
fi

if [[ -f "${ZDOTDIR:-$HOME}/.zshenv.local" ]]; then
  source "${ZDOTDIR:-$HOME}/.zshenv.local"
fi

path=("${path[@]}")
