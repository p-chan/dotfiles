#!/usr/bin/env bash

cat > /dev/null

osascript -e 'display notification "タスクが完了しました" with title "Claude Code"' 2>/dev/null

exit 0
