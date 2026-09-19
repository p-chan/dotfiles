#!/usr/bin/env bash

set -euo pipefail

SUPPORTED_PUSH_COMMAND_REGEX='^[[:space:]]*git[[:space:]]+push([[:space:]]+(--force-with-lease(=[^[:space:]]+)?|--force|-f))?[[:space:]]*$'

main() {
  local hook_input bash_command context_file

  hook_input="$(cat)"
  bash_command="$(jq -r '.tool_input.command // ""' <<<"$hook_input")"
  context_file="${BASH_SOURCE[0]%.sh}.md"

  if [[ ! $bash_command =~ $SUPPORTED_PUSH_COMMAND_REGEX ]]; then
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
