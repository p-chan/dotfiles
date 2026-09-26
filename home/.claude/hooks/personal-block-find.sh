#!/usr/bin/env bash

# TODO: https://github.com/anthropics/claude-code/issues/48722 が修正されたら `if: "Bash(find *)"` に置き換える
cmd=$(jq -r '.tool_input.command // ""')

if echo "$cmd" | grep -qE '^find\b'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Use fd -u instead of find"
    }
  }'
fi
