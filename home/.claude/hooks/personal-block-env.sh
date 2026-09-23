#!/usr/bin/env bash

# Permission rules cannot exclude .env*.example from .env* because deny rules have no negation
# Match case-insensitively because the default macOS file system is case-insensitive
if ! output=$(jq -c '
  (.tool_input.file_path // .tool_input.notebook_path // "" | split("/") | last // "" | ascii_downcase) as $name
  | if ($name | startswith(".env")) and ($name | endswith(".example") | not) then
      {
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "deny",
          permissionDecisionReason: "Reading or editing .env files is not allowed (except .env*.example)"
        }
      }
    else
      empty
    end
'); then
  # Exit code 2 blocks the tool call, so a failed check does not allow access
  echo "Failed to check whether the file is a .env file" >&2
  exit 2
fi

if [[ -n "$output" ]]; then
  echo "$output"
fi
