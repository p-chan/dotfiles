#!/usr/bin/env bash

# TODO: Replace with `if: "Bash(grep *)"` once https://github.com/anthropics/claude-code/issues/48722 is fixed
cmd=$(jq -r '.tool_input.command // ""')

if echo "$cmd" | grep -qE '^grep\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Use rg -uuu instead of grep"
    }
  }'
fi
