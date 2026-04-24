#!/usr/bin/env bash

# TODO: Replace with `if: "Bash(git -C *)"` once https://github.com/anthropics/claude-code/issues/48722 is fixed
cmd=$(jq -r '.tool_input.command // ""')

if echo "$cmd" | grep -qE '^git[[:space:]]+-C\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Do not use git -C. Run git commands from the working directory directly."
    }
  }'
fi
