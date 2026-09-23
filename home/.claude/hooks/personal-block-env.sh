#!/usr/bin/env bash

# Permission rules cannot exclude .env*.example from .env* because deny rules have no negation
path=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // ""')
name=$(basename -- "$path")

if [[ "$name" == .env* && "$name" != .env*.example ]]; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Reading or editing .env files is not allowed (except .env*.example)"
    }
  }'
fi
