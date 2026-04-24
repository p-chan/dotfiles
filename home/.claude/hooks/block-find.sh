#!/usr/bin/env bash

jq -n '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: "Use fd -u instead of find"
  }
}'
