#!/usr/bin/env bash
# Claude Code status indicator for tmux window
# Usage: claude-code-status.sh <window_id>

window_id="${1:-}"

if [[ -z "$window_id" ]]; then
  exit 0
fi

# Get pane titles for the specified window
pane_titles=$(tmux list-panes -t "$window_id" -F '#{pane_title}' 2>/dev/null)

if [[ -z "$pane_titles" ]]; then
  exit 0
fi

# Check for Claude Code status
# ⠐ (U+2810) or ⠂ (U+2802) = running (spinner animation)
# ✳ (U+2733) = idle (waiting for input)
if echo "$pane_titles" | grep -q '[⠐⠂]'; then
  # Alternate between ⠐ and ⠂ based on current second
  if (( $(date +%s) % 2 == 0 )); then
    printf ' ⠐'
  else
    printf ' ⠂'
  fi
elif echo "$pane_titles" | grep -q '✳'; then
  printf ' ✳'  # Idle
fi
