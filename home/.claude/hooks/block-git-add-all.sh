#!/usr/bin/env bash

cmd=$(jq -r '.tool_input.command // ""')

if [[ $cmd =~ ^git[[:space:]]+add[[:space:]]+-A$ ]]; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Do not use git add -A because it stages every change in the repository. Stage the intended paths explicitly with git add <path>."
    }
  }'
fi
