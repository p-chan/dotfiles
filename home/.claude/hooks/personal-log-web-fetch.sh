#!/usr/bin/env bash

INPUT=$(cat)

URL=$(echo "$INPUT" | jq -r '.tool_input.url // ""')
[ -z "$URL" ] && exit 0

mkdir -p ~/.claude/logs
echo "$(date -Iseconds) $URL" >> ~/.claude/logs/web-fetch.log
