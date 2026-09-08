#!/bin/bash

set -e

if [ -z "${DOTFILES_DIR:-}" ] || [ ! -d "$DOTFILES_DIR" ]; then
  echo "DOTFILES_DIR does not point at a dotfiles checkout." >&2
  exit 1
fi

CLAUDE_SETTINGS_RELATIVE_PATH="home/.claude/settings.json"
CLAUDE_SETTINGS_PATH="$DOTFILES_DIR/$CLAUDE_SETTINGS_RELATIVE_PATH"
CLAUDE_SETTINGS_TEMP_PATH="$(mktemp "$CLAUDE_SETTINGS_PATH.XXXXXX")"
trap 'rm -f "$CLAUDE_SETTINGS_TEMP_PATH"' EXIT

cp -p "$CLAUDE_SETTINGS_PATH" "$CLAUDE_SETTINGS_TEMP_PATH"
/bin/bash "$HOME/.config/git/filters/claude-settings.sh" smudge \
  < "$CLAUDE_SETTINGS_PATH" > "$CLAUDE_SETTINGS_TEMP_PATH"

if cmp -s "$CLAUDE_SETTINGS_PATH" "$CLAUDE_SETTINGS_TEMP_PATH"; then
  rm "$CLAUDE_SETTINGS_TEMP_PATH"
else
  mv "$CLAUDE_SETTINGS_TEMP_PATH" "$CLAUDE_SETTINGS_PATH"
fi
trap - EXIT

herdr integration install claude

# Refresh the stat cache only when neither index nor worktree has semantic changes.
if git -C "$DOTFILES_DIR" diff --cached --quiet -- "$CLAUDE_SETTINGS_RELATIVE_PATH"; then
  if git -C "$DOTFILES_DIR" diff --quiet -- "$CLAUDE_SETTINGS_RELATIVE_PATH"; then
    git -C "$DOTFILES_DIR" add -- "$CLAUDE_SETTINGS_RELATIVE_PATH"
  else
    status=$?
    if [ "$status" -ne 1 ]; then
      exit "$status"
    fi
  fi
else
  status=$?
  if [ "$status" -ne 1 ]; then
    exit "$status"
  fi
fi
