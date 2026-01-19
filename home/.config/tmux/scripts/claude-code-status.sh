#!/usr/bin/env bash
set -euo pipefail
# Claude Code status indicator for tmux window
# Usage: claude-code-status.sh <window_id>

window_id="${1:-}"

if [[ -z "$window_id" ]]; then
  exit 0
fi

# Get pane info for the specified window
pane_info=$(tmux list-panes -t "$window_id" -F '#{pane_current_command}|#{pane_title}' 2>/dev/null)

if [[ -z "$pane_info" ]]; then
  exit 0
fi

# Check if Claude Code is actually running
# Process name varies by installation method:
# - Homebrew: "claude"
# - Native: version number (e.g., "2.1.12")
# NOTE: Native installation showing version number as process name is likely a bug
# and may be fixed in the future: https://github.com/anthropics/claude-code/issues/12433
has_claude=false
pane_titles=""

while IFS='|' read -r command title; do
  if [[ "$command" == "claude" ]] || [[ "$command" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    has_claude=true
  fi
  pane_titles+="$title"$'\n'
done <<< "$pane_info"
# Remove trailing newline
pane_titles="${pane_titles%$'\n'}"

# Only show status if Claude Code is actually running
if [[ "$has_claude" == false ]]; then
  exit 0
fi

# Check for Claude Code status
# ⠐ (U+2810) or ⠂ (U+2802) = running (spinner animation)
# ✳ (U+2733) = idle (waiting for input)
if [[ "$pane_titles" =~ [⠐⠂] ]]; then
  # Alternate between ⠐ and ⠂ based on current second
  if (( $(date +%s) % 2 == 0 )); then
    printf ' ⠐'
  else
    printf ' ⠂'
  fi
elif [[ "$pane_titles" == *✳* ]]; then
  printf ' ✳'  # Idle
fi
