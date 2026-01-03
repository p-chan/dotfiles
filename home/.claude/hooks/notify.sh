#!/usr/bin/env bash

input=$(cat)

input_message=$(echo "$input" | jq -r '.message // empty')
cwd=$(echo "$input" | jq -r '.cwd // empty')
hook_event=$(echo "$input" | jq -r '.hook_event_name // empty')

# Set default message based on hook event
case "$hook_event" in
  "Notification")
    default_message="⏸️ 入力が必要です"
    ;;
  "Stop")
    default_message="✅ タスクが完了しました"
    ;;
  *)
    default_message="📢 通知"
    ;;
esac

if [ -n "$input_message" ]; then
  message="$input_message"
else
  message="$default_message"
fi

# Build subtitle: "repo on branch"
if [ -n "$cwd" ]; then
  repo=$(basename "$cwd")
  branch=$(cd "$cwd" && git branch --show-current 2>/dev/null)

  if [ -n "$branch" ]; then
    subtitle="$repo on $branch"
  else
    subtitle="$repo"
  fi
else
  subtitle=""
fi

# Detect terminal environment
case "$TERM_PROGRAM" in
  "vscode")
    title="Claude Code on VSCode"
    ;;
  "ghostty")
    title="Claude Code on Ghostty"
    ;;
  *)
    title="Claude Code"
    ;;
esac

terminal-notifier \
  -title "$title" \
  -subtitle "$subtitle" \
  -message "$message" \
  -group "claude-code" \
  2>/dev/null

exit 0
