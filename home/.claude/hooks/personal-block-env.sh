#!/usr/bin/env bash

# deny ルールには否定がなく、パーミッションルールでは .env* から .env*.example を除外できないため、フックで判定する
# macOS のデフォルトのファイルシステムは大文字と小文字を区別しないので、大文字と小文字を区別せずにマッチさせる
if ! output=$(jq -c '
  (.tool_input.file_path // .tool_input.notebook_path // "" | split("/") | last // "" | ascii_downcase) as $name
  | if ($name | startswith(".env")) and ($name | endswith(".example") | not) then
      {
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "deny",
          permissionDecisionReason: "Reading or editing .env files is not allowed (except .env*.example)"
        }
      }
    else
      empty
    end
'); then
  # 終了コード 2 はツールの呼び出しをブロックするので、判定に失敗してもアクセスを許可しない
  echo "Failed to check whether the file is a .env file" >&2
  exit 2
fi

if [[ -n "$output" ]]; then
  echo "$output"
fi
