#!/usr/bin/env bash

set -euo pipefail

mode="${1:-}"
portable_command='bash "$HOME/.claude/hooks/herdr-agent-state.sh" session'

case "$mode" in
  clean)
    jq --arg portable_command "$portable_command" '
      walk(
        if type == "string" and test("^bash '\''[^'\'']*/\\.claude/hooks/herdr-agent-state\\.sh'\'' session$") then
          $portable_command
        else
          .
        end
      )
    '
    ;;
  smudge)
    jq --arg portable_command "$portable_command" --arg home "$HOME" '
      walk(
        if type == "string" and . == $portable_command then
          "bash '\''\($home)/.claude/hooks/herdr-agent-state.sh'\'' session"
        else
          .
        end
      )
    '
    ;;
  *)
    echo "Usage: git-filter-claude-settings.sh <clean|smudge>" >&2
    exit 1
    ;;
esac
