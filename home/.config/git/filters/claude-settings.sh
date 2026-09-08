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
    const { TextDecoder } = require("node:util");
    const chunks = [];
    process.stdin.on("data", (chunk) => { chunks.push(chunk); });
    process.stdin.on("end", () => {
      try {
        const input = Buffer.concat(chunks);
        const value = JSON.parse(new TextDecoder("utf-8", { fatal: true }).decode(input));
        if (value === null || Array.isArray(value) || typeof value !== "object") {
          throw new Error("Claude settings must be a JSON object");
        }
        process.stdout.write(input);
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
      def references_herdr_script:
        explode
        | map(select(. != 34 and . != 39 and . != 92))
        | implode
        | ascii_downcase
        | contains("herdr-agent-state.sh");

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
          references_herdr_script and . != $portable_command
        ) then
          error("unsupported Herdr Claude hook command")
        else
          .
        end
    '
    ;;
  smudge)
    validate_json | jq --arg local_command "$local_command" --arg portable_command "$portable_command" '
      def references_herdr_script:
        explode
        | map(select(. != 34 and . != 39 and . != 92))
        | implode
        | ascii_downcase
        | contains("herdr-agent-state.sh");

      walk(
        if type == "string" and . == $portable_command then
          $local_command
        else
          .
        end
      )
      | if any(
          .. | strings;
          references_herdr_script and . != $local_command
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
