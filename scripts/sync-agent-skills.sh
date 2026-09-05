#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
DOTFILES_DIR="${1:-$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)}"
MANIFEST="$DOTFILES_DIR/home/.agents/external-skills"
SKILLS_DIR="$DOTFILES_DIR/home/.agents/skills"
STATE_FILE="$SKILLS_DIR/.external-skills"
TEMP_DIR="$(mktemp -d)"
DESIRED_NAMES="$TEMP_DIR/names"
: > "$DESIRED_NAMES"

cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

fail() {
  printf '%s\n' "sync-agent-skills: $*" >&2
  exit 1
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  printf '%s' "${value%"${value##*[![:space:]]}"}"
}

repository_url() {
  case "$1" in
    *://*|git@*|ssh://*) printf '%s' "$1" ;;
    */*) printf 'https://github.com/%s.git' "$1" ;;
    *) fail "invalid repository: $1" ;;
  esac
}

is_desired() {
  local name="$1"
  local desired_name

  while IFS= read -r desired_name; do
    [ "$desired_name" != "$name" ] || return 0
  done < "$DESIRED_NAMES"

  return 1
}

[ -f "$MANIFEST" ] || fail "manifest not found: $MANIFEST"
mkdir -p "$SKILLS_DIR"

while IFS= read -r raw_locator || [ -n "$raw_locator" ]; do
  locator="$(trim "$raw_locator")"
  case "$locator" in
    ''|'#'*) continue ;;
  esac

  repository="${locator%%#*}"
  reference_and_path="${locator#*#}"
  [ "$repository" != "$locator" ] || fail "missing # in locator: $locator"

  reference="${reference_and_path%%:*}"
  path_and_name="${reference_and_path#*:}"
  [ "$reference" != "$reference_and_path" ] || fail "missing : in locator: $locator"

  skill_path="${path_and_name%%=*}"
  skill_name="${path_and_name#*=}"
  if [ "$skill_name" = "$path_and_name" ]; then
    skill_name="${skill_path%/}"
    skill_name="${skill_name##*/}"
  fi

  [ "${#reference}" -eq 40 ] && [[ "$reference" != *[!0-9a-f]* ]] || fail "reference must be a 40-character commit SHA: $locator"
  case "$skill_path" in
    ''|/*|../*|*/../*|*/..) fail "invalid skill path: $locator" ;;
  esac
  case "$skill_name" in
    ''|.|..|*/*) fail "invalid skill name: $locator" ;;
  esac

  is_desired "$skill_name" && fail "duplicate skill name: $skill_name"
  printf '%s\n' "$skill_name" >> "$DESIRED_NAMES"

  checkout="$TEMP_DIR/$skill_name"
  git init --quiet "$checkout"
  git -C "$checkout" remote add origin "$(repository_url "$repository")"
  git -C "$checkout" fetch --depth=1 --quiet origin "$reference"
  git -C "$checkout" checkout --detach --quiet FETCH_HEAD
  [ "$(git -C "$checkout" rev-parse HEAD)" = "$reference" ] || fail "resolved a different commit for: $locator"

  source_dir="$checkout/$skill_path"
  [ -d "$source_dir" ] && [ -f "$source_dir/SKILL.md" ] || fail "skill not found: $locator"

  # Copy first so a failed download never removes a working installed skill.
  staging_dir="$SKILLS_DIR/.${skill_name}.tmp.$$"
  rm -rf "$staging_dir"
  cp -R "$source_dir" "$staging_dir"
  rm -rf "$SKILLS_DIR/$skill_name"
  mv "$staging_dir" "$SKILLS_DIR/$skill_name"

  printf 'Installed %s\n' "$skill_name"
done < "$MANIFEST"

if [ -f "$STATE_FILE" ]; then
  while IFS= read -r installed_name; do
    [ -z "$installed_name" ] || is_desired "$installed_name" || rm -rf "$SKILLS_DIR/$installed_name"
  done < "$STATE_FILE"
fi

mv "$DESIRED_NAMES" "$STATE_FILE"
