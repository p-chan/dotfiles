#!/usr/bin/env bash

# TODO: https://github.com/anthropics/claude-code/issues/48722 が修正されたら `if: "Bash(git -C *)"` に置き換える
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
