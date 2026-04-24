#!/usr/bin/env bash

jq -n '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: "Do not use git -C. Run git commands from the working directory directly."
  }
}'
