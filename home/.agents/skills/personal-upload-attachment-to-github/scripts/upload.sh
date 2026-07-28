#!/bin/bash
#
# ローカルファイルを GitHub の user-attachments にアップロードし、URL を出力する
#
# 【重要な制約】
# GitHub が Web UI のために用意している、公式ドキュメントに記載のないエンドポイントを使っている。
# 予告なく仕様が変わる可能性がある。
# 参考: https://github.com/cli/cli/issues/13256
#
# 使い方: upload.sh <file-path> [repository_id]
#
# - repository_id を省略した場合、カレントディレクトリの git remote から解決する
# - Content-Type は拡張子から判定し、未知の拡張子は file コマンドにフォールバックする
# - 成功時は URL を stdout に出力し、失敗時は stderr にエラーを出して exit 1
#

set -euo pipefail

file_path="${1:-}"
repository_id="${2:-}"

if [[ -z "$file_path" ]]; then
  echo "使い方: upload.sh <file-path> [repository_id]" >&2
  exit 1
fi

if [[ ! -f "$file_path" ]]; then
  echo "ファイルが見つかりません: $file_path" >&2
  exit 1
fi

token=$(gh auth token 2>/dev/null) || {
  echo "gh auth token に失敗しました。gh auth login を実行してください" >&2
  exit 1
}

# repository_id は数値の ID が必要（gh repo view --json id が返す node ID では通らない）
if [[ -z "$repository_id" ]]; then
  repository_id=$(gh api "repos/{owner}/{repo}" --jq .id 2>/dev/null) || {
    echo "repository_id の解決に失敗しました。第 2 引数で明示してください" >&2
    exit 1
  }
fi

file_name=$(basename "$file_path")
extension=$(printf '%s' "${file_name##*.}" | tr '[:upper:]' '[:lower:]')

case "$extension" in
  png) content_type="image/png" ;;
  jpg | jpeg) content_type="image/jpeg" ;;
  gif) content_type="image/gif" ;;
  webp) content_type="image/webp" ;;
  svg) content_type="image/svg+xml" ;;
  mp4) content_type="video/mp4" ;;
  mov) content_type="video/quicktime" ;;
  webm) content_type="video/webm" ;;
  *) content_type=$(file --mime-type -b "$file_path" 2>/dev/null || echo "application/octet-stream") ;;
esac

# クエリ文字列に載せるため、URL エンコードする
# 特に content_type の "image/svg+xml" は、+ を素で渡すと空白として解釈される
encode() {
  jq -rn --arg value "$1" '$value | @uri'
}

response_body=$(mktemp)
trap 'rm -f "$response_body"' EXIT

query="name=$(encode "$file_name")"
query="${query}&content_type=$(encode "$content_type")"
query="${query}&repository_id=$(encode "$repository_id")"

http_code=$(
  curl -sS \
    -X POST \
    -H "Authorization: Bearer ${token}" \
    -H "Content-Type: application/octet-stream" \
    -H "Accept: application/json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    --data-binary "@${file_path}" \
    -o "$response_body" \
    -w '%{http_code}' \
    "https://uploads.github.com/user-attachments/assets?${query}"
)

url=$(jq -r '.url // empty' <"$response_body" 2>/dev/null || true)

if [[ -z "$url" ]]; then
  echo "アップロードに失敗しました (HTTP ${http_code})" >&2
  echo "$(<"$response_body")" >&2
  exit 1
fi

echo "$url"
