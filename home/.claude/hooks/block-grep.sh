#!/usr/bin/env bash

jq -n '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: "Use rg -uuu instead of grep"
  }
}'
