#!/usr/bin/env bash

set -euo pipefail

mode="${1:-}"
hook_path="$HOME/.claude/hooks/herdr-agent-state.sh"
single_quote="'"
single_quote_escape="'\"'\"'"
escaped_hook_path="${hook_path//$single_quote/$single_quote_escape}"
local_command="bash '$escaped_hook_path' session"
portable_command='bash "$HOME/.claude/hooks/herdr-agent-state.sh" session'

case "$mode" in
  clean)
    jq -S --slurp --arg local_command "$local_command" --arg portable_command "$portable_command" '
      if length == 1 and (.[0] | type) == "object" then
        .[0]
      else
        error("Claude settings must be a single JSON object")
      end
      | walk(
        if type == "string" and . == $local_command then
          $portable_command
        elif type == "array" then
          sort
        else
          .
        end
      )
      | if any(
          .. | strings;
          contains("/.claude/hooks/herdr-agent-state.sh") and . != $portable_command
        ) then
          error("unsupported Herdr Claude hook command")
        else
          .
        end
    '
    ;;
  smudge)
    jq --slurp --arg local_command "$local_command" --arg portable_command "$portable_command" '
      if length == 1 and (.[0] | type) == "object" then
        .[0]
      else
        error("Claude settings must be a single JSON object")
      end
      | walk(
        if type == "string" and . == $portable_command then
          $local_command
        else
          .
        end
      )
    '
    ;;
  *)
    echo "Usage: claude-settings.sh <clean|smudge>" >&2
    exit 1
    ;;
esac
