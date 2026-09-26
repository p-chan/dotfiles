#!/usr/bin/env bash
# Claude Code のステータスライン
# 形式: currentDir on branchName* (#PR1, #PR2)
#         Model: <model> | Context: <pct>% | 5h: <pct>% (<time>) | 7d: <pct>% (<time>)

# 標準入力から JSON を読み込む（入力がある場合）
input=$(cat 2>/dev/null || echo '{}')

# jq が使えるか確認する
if ! command -v jq >/dev/null 2>&1; then
  printf 'Claude Code (jq not found)'
  exit 0
fi

# ANSI カラーコード
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
GRAY=$'\033[90m'
RESET=$'\033[0m'

# Anthropic のブランドカラー（True Color）
ORANGE=$'\033[38;2;217;119;87m'  # #d97757

# PR の状態ごとの色（GitHub 風、True Color）
PR_OPEN_FG=$'\033[38;2;63;185;80m'      # #3fb950
PR_CLOSED_FG=$'\033[38;2;248;81;73m'    # #f85149
PR_DRAFT_FG=$'\033[38;2;145;152;161m'   # #9198a1
PR_MERGED_FG=$'\033[38;2;171;125;248m'  # #ab7df8

# PR の状態ごとのアイコン（Nerd Font）
ICON_OPEN=$(printf '\xEF\x90\x87')     # nf-oct-git_pull_request (U+F407)
ICON_CLOSED=$(printf '\xEF\x93\x9C')   # nf-oct-git_pull_request_closed (U+F4DC)
ICON_DRAFT=$(printf '\xEF\x93\x9D')    # nf-oct-git_pull_request_draft (U+F4DD)
ICON_MERGED=$(printf '\xEF\x90\x99')   # nf-oct-git_merge (U+F419)

# JSON から現在のディレクトリを取り出す
raw_dir=$(echo "$input" | jq -r '.workspace.current_dir // empty' 2>/dev/null)
if [[ -z "$raw_dir" || "$raw_dir" == "null" ]]; then
  raw_dir="$PWD"
fi
current_dir=$(basename "$raw_dir")

# Git のブランチと未コミットの変更の有無を取得する
git_branch=""
git_diff=""
if git rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(git branch --show-current 2>/dev/null)
  if [[ -n "$(git status --short 2>/dev/null)" ]]; then
    git_diff="*"
  fi

  # worktree（git-wt で作成したものなど）の中では、worktree のディレクトリ名ではなくメインのリポジトリ名を表示する
  # worktree のディレクトリはブランチ名で命名されることが多く、"on" のあとに表示するブランチ名と重複するため（"branch-name on branch-name" など）
  git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null)
  if [[ -n "$git_common_dir" ]]; then
    [[ "$git_common_dir" != /* ]] && git_common_dir="$raw_dir/$git_common_dir"
    main_root=$(cd "$(dirname "$git_common_dir")" 2>/dev/null && pwd)
    [[ -n "$main_root" ]] && current_dir=$(basename "$main_root")
  fi
fi

# PR の番号をハイパーリンク付きで取得する（gh CLI が使える場合）
pr_numbers=""
if command -v gh >/dev/null 2>&1; then
  repo_url=$(gh repo view --json url -q .url 2>/dev/null)
  if [[ -n "$repo_url" ]]; then
    # すべての PR の番号、状態、ドラフトかどうかを取得する
    pr_list=$(gh pr list --head "$git_branch" --json number,state,isDraft 2>/dev/null)
    pr_links=""
    while IFS= read -r pr_json; do
      [[ -z "$pr_json" ]] && continue
      num=$(echo "$pr_json" | jq -r '.number')
      state=$(echo "$pr_json" | jq -r '.state')
      is_draft=$(echo "$pr_json" | jq -r '.isDraft')

      # 状態に応じて色とアイコンを決める
      if [[ "$is_draft" == "true" ]]; then
        fg="$PR_DRAFT_FG"
        icon="$ICON_DRAFT"
      elif [[ "$state" == "MERGED" ]]; then
        fg="$PR_MERGED_FG"
        icon="$ICON_MERGED"
      elif [[ "$state" == "CLOSED" ]]; then
        fg="$PR_CLOSED_FG"
        icon="$ICON_CLOSED"
      else
        fg="$PR_OPEN_FG"
        icon="$ICON_OPEN"
      fi

      # ターミナルに応じてリンクのスタイルを決める
      if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
        link_style=$'\033[4m'  # 下線
      else
        link_style=""
      fi

      # 状態の色を付けたアイコンのあとに、#NUM のハイパーリンクを続ける
      # OSC 8 のハイパーリンクの形式: \033]8;;URL\007text\033]8;;\007
      link="${fg}${icon}${RESET} ${link_style}"$'\033]8;;'"${repo_url}/pull/${num}"$'\007'"#${num}"$'\033]8;;\007'"${RESET}"
      if [[ -n "$pr_links" ]]; then
        pr_links+=", ${link}"
      else
        pr_links="${link}"
      fi
    done <<< "$(echo "$pr_list" | jq -c '.[]' 2>/dev/null)"
    pr_numbers="$pr_links"
  fi
fi

# JSON から情報を取り出す
model=$(echo "$input" | jq -r '.model.display_name // empty' 2>/dev/null)
effort=$(echo "$input" | jq -r '.effort.level // empty' 2>/dev/null)
context_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty' 2>/dev/null)

# 標準入力の JSON から使用率とリセット時刻を取り出す
five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' 2>/dev/null)
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' 2>/dev/null)
five_hour_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty' 2>/dev/null)
seven_day_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty' 2>/dev/null)

# リセットまでの時間を読みやすい形式で算出する
time_until() {
  local reset_epoch=$1
  if [[ -z "$reset_epoch" || "$reset_epoch" == "null" ]]; then
    echo ""
    return
  fi

  local now_epoch=$(date +%s)
  local diff=$((reset_epoch - now_epoch))

  if [[ $diff -le 0 ]]; then
    echo ""
    return
  fi

  # 読みやすい形式に変換する
  local days=$((diff / 86400))
  local hours=$(((diff % 86400) / 3600))
  local minutes=$(((diff % 3600) / 60))

  if [[ $days -gt 0 ]]; then
    echo "${days}d"
  elif [[ $hours -gt 0 ]]; then
    echo "${hours}h"
  elif [[ $minutes -gt 0 ]]; then
    echo "${minutes}m"
  else
    echo "<1m"
  fi
}

# 出力する要素を組み立てる
output=""

# ディレクトリ、ブランチ、PR（色は starship.toml に合わせる）
output+="${YELLOW}${current_dir}${RESET}"
if [[ -n "$git_branch" ]]; then
  output+=" on ${GREEN}${git_branch}${git_diff}${RESET}"
fi
if [[ -n "$pr_numbers" ]]; then
  output+=" (${pr_numbers})"
fi

# モデル
if [[ -n "$model" && "$model" != "null" ]]; then
  output+=$'\n'
  output+="Model: ${ORANGE}${model}${RESET}"
  if [[ -n "$effort" && "$effort" != "null" ]]; then
    output+=" (${effort})"
  fi
fi

# コンテキストの使用率
if [[ -n "$context_pct" && "$context_pct" != "null" ]]; then
  percent=$(printf "%.0f" "$context_pct" 2>/dev/null || echo "$context_pct")
  output+=" ${GRAY}|${RESET} Context: ${percent}%"
fi

# 使用量
usage_parts=""

# 5 時間の上限
if [[ -n "$five_hour_pct" && "$five_hour_pct" != "null" ]]; then
  five_hour_int=$(printf "%.0f" "$five_hour_pct" 2>/dev/null || echo "$five_hour_pct")
  usage_parts+="5h: ${five_hour_int}%"

  # リセット時刻を追加する
  five_hour_time=$(time_until "$five_hour_reset")
  if [[ -n "$five_hour_time" ]]; then
    usage_parts+=" (${five_hour_time})"
  fi
fi

# 7 日間の上限
if [[ -n "$seven_day_pct" && "$seven_day_pct" != "null" ]]; then
  seven_day_int=$(printf "%.0f" "$seven_day_pct" 2>/dev/null || echo "$seven_day_pct")
  [[ -n "$usage_parts" ]] && usage_parts+=" ${GRAY}|${RESET} "
  usage_parts+="7d: ${seven_day_int}%"

  # リセット時刻を追加する
  seven_day_time=$(time_until "$seven_day_reset")
  if [[ -n "$seven_day_time" ]]; then
    usage_parts+=" (${seven_day_time})"
  fi
fi

if [[ -n "$usage_parts" ]]; then
  [[ -n "$output" ]] && output+=" ${GRAY}|${RESET} "
  output+="${usage_parts}"
fi

# データがない場合のフォールバック
if [[ -z "$output" ]]; then
  output="Claude Code"
fi

printf '%s' "$output"
