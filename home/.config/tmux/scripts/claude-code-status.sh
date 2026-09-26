#!/usr/bin/env bash
set -euo pipefail
# tmux のウィンドウに Claude Code の状態を表示する
# 使い方: claude-code-status.sh <window_id> <window_name>

window_id="${1:-}"
window_name="${2:-}"

if [[ -z "$window_id" ]]; then
  printf '%s' "$window_name"
  exit 0
fi

# 指定したウィンドウのペインの情報を取得する
pane_info=$(tmux list-panes -t "$window_id" -F '#{pane_current_command}|#{pane_title}' 2>/dev/null)

if [[ -z "$pane_info" ]]; then
  printf '%s' "$window_name"
  exit 0
fi

# Claude Code が実際に動いているか確認する
# プロセス名はインストール方法によって異なる
# - Homebrew: "claude"
# - ネイティブ: バージョン番号（"2.1.12" など）
# NOTE: ネイティブ版でプロセス名がバージョン番号になるのはバグの可能性があり、将来修正されるかもしれない
# https://github.com/anthropics/claude-code/issues/12433
has_claude=false
pane_titles=""

while IFS='|' read -r command title; do
  if [[ "$command" == "claude" ]] || [[ "$command" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    has_claude=true
  fi
  pane_titles+="$title"$'\n'
done <<< "$pane_info"
# 末尾の改行を取り除く
pane_titles="${pane_titles%$'\n'}"

# Claude Code が実際に動いている場合だけ状態を表示する
if [[ "$has_claude" == false ]]; then
  printf '%s' "$window_name"
  exit 0
fi

# ウィンドウ名のバージョン番号を "claude" に置き換える
display_name="$window_name"
if [[ "$window_name" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  display_name="claude"
fi

# Claude Code の状態を確認する
# ⠐ (U+2810) または ⠂ (U+2802) = 実行中（スピナーのアニメーション）
# ✳ (U+2733) = アイドル（入力待ち）
if [[ "$pane_titles" =~ [⠐⠂] ]]; then
  # 現在の秒数に応じて ⠐ と ⠂ を交互に表示する
  if (( $(date +%s) % 2 == 0 )); then
    printf '%s ⠐' "$display_name"
  else
    printf '%s ⠂' "$display_name"
  fi
elif [[ "$pane_titles" == *✳* ]]; then
  printf '%s ✳' "$display_name"
else
  printf '%s' "$display_name"
fi
