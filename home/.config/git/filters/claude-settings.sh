#!/usr/bin/env bash

set -euo pipefail

mode="${1:-}"
hook_path="$HOME/.claude/hooks/herdr-agent-state.sh"
single_quote="'"
single_quote_escape="'\"'\"'"
escaped_hook_path="${hook_path//$single_quote/$single_quote_escape}"
local_command="bash '$escaped_hook_path' session"
# shellcheck disable=SC2016
portable_command='bash "$HOME/.claude/hooks/herdr-agent-state.sh" session'

validate_json() {
  node -e '
    let input = "";
    process.stdin.setEncoding("utf8");
    process.stdin.on("data", (chunk) => { input += chunk; });
    process.stdin.on("end", () => {
      try {
        const value = JSON.parse(input);
        if (value === null || Array.isArray(value) || typeof value !== "object") {
          throw new Error("Claude settings must be a JSON object");
        }
        process.stdout.write(JSON.stringify(value));
      } catch (error) {
        console.error(error.message);
        process.exitCode = 1;
      }
    });
  '
}

case "$mode" in
  clean)
    validate_json | jq -S --arg local_command "$local_command" --arg portable_command "$portable_command" '
      walk(
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
          contains("herdr-agent-state.sh") and . != $portable_command
        ) then
          error("unsupported Herdr Claude hook command")
        else
          .
        end
    '
    ;;
  smudge)
    validate_json | jq --arg local_command "$local_command" --arg portable_command "$portable_command" '
      walk(
        if type == "string" and . == $portable_command then
          $local_command
        else
          .
        end
      )
      | if any(
          .. | strings;
          contains("herdr-agent-state.sh") and . != $local_command
        ) then
          error("unsupported Herdr Claude hook command")
        else
          .
        end
    '
    ;;
  *)
    echo "Usage: claude-settings.sh <clean|smudge>" >&2
    exit 1
    ;;
esac
