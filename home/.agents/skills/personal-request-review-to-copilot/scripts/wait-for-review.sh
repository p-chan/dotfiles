#!/usr/bin/env bash
set -euo pipefail

# GitHub Copilot がレビューを投稿するまで待ちます。
# 判定条件の詳細は usage()（`--help` / `-h`）に集約しています。

usage() {
  cat <<'EOF'
Usage: wait-for-review.sh [--pr <number>] [--poll-interval <seconds>] [--timeout <seconds>] [--help|-h]

GitHub Copilot がレビューを投稿するまで待ちます。レビューの依頼は行いません。

Options:
  --pr <number>              対象の PR 番号（省略時は gh pr view で現在のブランチの PR）
  --poll-interval <seconds>  ポーリング間隔（既定: 30）
  --timeout <seconds>        待機の上限（既定: 900）
  --help, -h                 このヘルプを表示して終了

完了判定（最終行に結果を出力する）

  timeline API から Copilot への最後のレビュー依頼と、Copilot の最後のレビュー投稿の
  時刻を取り、後者が前者より新しければ完了とみなす。再依頼のたびに依頼の時刻が進むため、
  過去のレビューを新しいレビューと誤認しない。

  最後の依頼より新しいレビューがある → REVIEWED（exit 0）
  Copilot へのレビュー依頼が無い     → NOT_REQUESTED（exit 1）
  --timeout 経過                     → TIMEOUT（exit 1）
  API の取得に失敗したまま期限経過   → ERROR（exit 1）

  timeline API の取得に失敗しても即座には終了せず、期限内は再試行する。通信断や
  一時的な API エラーで待機が終わらないようにするため。
EOF
}

# Copilot のレビュー依頼と投稿は timeline API 上ではこの login で記録される
readonly COPILOT_LOGIN='Copilot'

PR=""
POLL_INTERVAL=30
TIMEOUT=900

# 数値の引数を検証して、10 進数に正規化した結果を NUMBER に入れる。
# bash の算術評価は先頭ゼロ付きの値を 8 進数として解釈するため、10# を付けて渡す。
# コマンド置換の中では exit がサブシェルしか抜けないため、戻り値ではなく変数で渡す
NUMBER=0
require_number() {
  local option="$1" value="$2" min="$3"
  if [[ ! "${value}" =~ ^[0-9]+$ ]]; then
    echo "error: ${option} requires a non-negative integer, got: ${value}" >&2
    exit 1
  fi

  NUMBER=$((10#${value}))
  if ((NUMBER < min)); then
    echo "error: ${option} must be ${min} or greater, got: ${value}" >&2
    exit 1
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help | -h)
      usage
      exit 0
      ;;
    --pr)
      if [[ $# -lt 2 ]]; then
        echo "error: --pr requires a number" >&2
        exit 1
      fi
      require_number --pr "$2" 1
      PR="${NUMBER}"
      shift 2
      ;;
    --poll-interval)
      if [[ $# -lt 2 ]]; then
        echo "error: --poll-interval requires seconds" >&2
        exit 1
      fi
      # 0 を許すと sleep 0 のタイトループになり、gh api を連続起動して
      # API のレート制限と CPU を消費するため 1 秒以上を必須にする
      require_number --poll-interval "$2" 1
      POLL_INTERVAL="${NUMBER}"
      shift 2
      ;;
    --timeout)
      if [[ $# -lt 2 ]]; then
        echo "error: --timeout requires seconds" >&2
        exit 1
      fi
      require_number --timeout "$2" 0
      TIMEOUT="${NUMBER}"
      shift 2
      ;;
    *)
      echo "error: unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "${PR}" ]]; then
  if ! PR="$(gh pr view --json number --jq '.number')"; then
    echo "error: 現在のブランチの PR を特定できません。--pr で PR 番号を指定してください" >&2
    exit 1
  fi
fi

# Copilot への最後のレビュー依頼と、Copilot の最後のレビュー投稿の時刻を
# "<requested_at> <reviewed_at>" として出力する。該当が無い側は空文字になる。
# review_requested は created_at、reviewed は submitted_at に時刻を持つ。
# 時刻は ISO 8601 の UTC で桁数が揃うため、文字列の昇順が時系列の順序と一致する。
# --paginate はページサイズを変えないため、ポーリングのリクエスト数を抑えるよう
# per_page で 1 ページを最大化する
copilot_review_times() {
  gh api "repos/{owner}/{repo}/issues/${PR}/timeline?per_page=100" --paginate --jq "
    .[]
    | select((.event == \"review_requested\" and .requested_reviewer.login == \"${COPILOT_LOGIN}\")
          or (.event == \"reviewed\" and .user.login == \"${COPILOT_LOGIN}\"))
    | \"\(.event) \(.created_at // .submitted_at)\"
  " | awk '
    $1 == "review_requested" && $2 > requested { requested = $2 }
    $1 == "reviewed" && $2 > reviewed { reviewed = $2 }
    END { print requested, reviewed }
  '
}

# 期限は絶対時刻ではなく経過時間で判定する。SECONDS はシェルの起動からの秒数で、
# 開始時刻との差を取れば時刻の桁数や書式に左右されない
started_at=${SECONDS}

api_failures=0

while true; do
  # 取得に失敗しても即座には終了しない。通信断や一時的な API エラーで
  # 待機が終わってしまわないよう、期限内は再試行する
  if times="$(copilot_review_times)"; then
    api_failures=0

    # awk は常に 2 つのフィールドを出すため、空のときも区切りの空白は残る
    requested_at="${times%% *}"
    reviewed_at="${times#* }"

    if [[ -z "${requested_at}" ]]; then
      echo "NOT_REQUESTED: PR #${PR} に Copilot へのレビュー依頼がありません"
      exit 1
    fi

    if [[ -n "${reviewed_at}" && "${reviewed_at}" > "${requested_at}" ]]; then
      echo "REVIEWED: Copilot がレビューを投稿しました（依頼: ${requested_at}, 投稿: ${reviewed_at}）"
      exit 0
    fi
  else
    api_failures=$((api_failures + 1))
    echo "warning: timeline API の取得に失敗しました（連続 ${api_failures} 回）。再試行します" >&2
  fi

  elapsed=$((SECONDS - started_at))
  if ((elapsed >= TIMEOUT)); then
    if ((api_failures > 0)); then
      echo "ERROR: timeline API の取得に失敗したまま ${TIMEOUT} 秒が経過しました（連続 ${api_failures} 回）"
      exit 1
    fi
    echo "TIMEOUT: ${TIMEOUT} 秒待ちましたが Copilot のレビューは投稿されませんでした"
    exit 1
  fi

  # 期限を越えて待たないよう、残り時間を超えない範囲で待つ
  remaining=$((TIMEOUT - elapsed))
  if ((remaining < POLL_INTERVAL)); then
    sleep "${remaining}"
  else
    sleep "${POLL_INTERVAL}"
  fi
done
