#!/usr/bin/env bash

# main working tree でのブランチの作成を禁止し、linked worktree に作らせる
# 意図して main working tree に作るときは、ALLOW_MAIN_WORKING_TREE=1 を前に付けて実行する
input=$(cat)
cmd=$(jq -r '.tool_input.command // ""' <<<"$input")
dir=$(jq -r '.cwd // ""' <<<"$input")
cmd=${cmd//ALLOW_MAIN_WORKING_TREE=1 git/:}

# && でつなげたコマンドの途中も対象にする。git branch は、オプションを付けずに名前を渡したとき（ブランチの作成）だけを対象にする
if ! echo "$cmd" | grep -qE '(^|[;&|(])[[:space:]]*([A-Za-z_][A-Za-z0-9_]*=[^[:space:]]*[[:space:]]+)*git[[:space:]]+((switch[[:space:]]+(-c|-C|--create)|checkout[[:space:]]+(-b|-B))([[:space:]=]|$)|branch[[:space:]]+[^-[:space:]])'; then
  exit 0
fi

# cd <path> && ... で始まる場合は、移動先で判定する
if [[ $cmd =~ ^[[:space:]]*cd[[:space:]]+([^;\&|[:space:]]+)[[:space:]]*\&\& ]]; then
  target=${BASH_REMATCH[1]}
  target=${target//\"/}
  target=${target//\'/}
  target=${target/#\~/$HOME}
  [[ $target == /* ]] || target="$dir/$target"
  dir=$target
fi

git_dir=$(cd "$dir" 2>/dev/null && git rev-parse --path-format=absolute --git-dir 2>/dev/null) || exit 0
common_dir=$(cd "$dir" && git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || exit 0

if [[ $git_dir == "$common_dir" ]]; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "Do not create branches in the main working tree. Create the branch in a new linked worktree as the personal-git skill describes."
    }
  }'
fi
