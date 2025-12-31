#!/usr/bin/env bash

LOG_DIR="${HOME}/.claude/logs"
LOG_FILE="${LOG_DIR}/permission-request.jsonl"

mkdir -p "${LOG_DIR}"

jq -c '. + {timestamp: (now | todate)}' | tee -a "${LOG_FILE}" > /dev/null

exit 0
