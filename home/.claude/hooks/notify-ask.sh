#!/usr/bin/env bash

cat > /dev/null

osascript -e 'display notification "入力が必要です" with title "Claude Code"' 2>/dev/null

exit 0
