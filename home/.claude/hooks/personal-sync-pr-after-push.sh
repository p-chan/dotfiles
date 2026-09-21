#!/usr/bin/env bash

set -euo pipefail

PUSH_COMMAND_REGEX='^[[:space:]]*git[[:space:]]+push([[:space:]]|$)'
EXCLUDED_PUSH_REGEX='(^|[[:space:]])(-d|--delete|--tags|--all|--mirror|-n|--dry-run)([[:space:]=]|$)|[[:space:]]:[^[:space:]]'

is_supported_push() {
  local segment

  while IFS= read -r segment; do
    [[ $segment =~ $PUSH_COMMAND_REGEX ]] || continue
    [[ $segment =~ $EXCLUDED_PUSH_REGEX ]] && continue
    return 0
  done < <(sed -E 's/(&&|\|\||;|\|)/\n/g' <<<"$1")

  return 1
}

main() {
  local hook_input bash_command context_file

  hook_input="$(cat)"
  bash_command="$(jq -r '.tool_input.command // ""' <<<"$hook_input")"
  context_file="${BASH_SOURCE[0]%.sh}.md"

  if ! is_supported_push "$bash_command"; then
    return 0
  fi

  jq -n --rawfile additionalContext "$context_file" '{
    hookSpecificOutput: {
      hookEventName: "PostToolUse",
      additionalContext: $additionalContext
    }
  }'
}

main
