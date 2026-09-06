import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { chmod, mkdir, mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const scriptPath = join(dirname(fileURLToPath(import.meta.url)), "wait-for-review.sh");

const COPILOT = "Copilot";
const REQUESTED_AT = "2026-08-10T09:52:05Z";
const REVIEWED_AT = "2026-08-10T09:58:50Z";
const LATER_AT = "2026-08-10T10:05:00Z";

type TimelineEvent = Record<string, unknown>;

// フィールドの持ち方は実際の timeline API に合わせている。
// スクリプトの jq 式や login 名を壊すとテストが落ちる
function request(at: string, login: string = COPILOT): TimelineEvent {
  return { event: "review_requested", created_at: at, requested_reviewer: { login } };
}

function review(at: string, login: string = COPILOT): TimelineEvent {
  return { event: "reviewed", submitted_at: at, user: { login } };
}

function unrelated(): TimelineEvent {
  return { event: "labeled", created_at: "2026-08-10T00:00:00Z", label: { name: "noise" } };
}

// gh api のモック。呼び出し回数ごとに timeline の応答を切り替え、--jq の式は実際の jq に
// 通すことで、スクリプトの jq 式そのものを検証対象にする。
// 応答が設定されていない回は、直前に設定された内容を返し続ける
const GH_MOCK = `#!/usr/bin/env bash
set -eo pipefail

if [[ "$1" == "api" ]]; then
  # --paginate が無いと timeline が複数ページのときに取りこぼすため、必須にする
  if [[ "$*" != *--paginate* ]]; then
    echo "unexpected gh api args (--paginate is required): $*" >&2
    exit 1
  fi

  # ページサイズを最大にしないとポーリングのリクエスト数が増えるため、必須にする
  if [[ "$*" != *per_page=100* ]]; then
    echo "unexpected gh api args (per_page=100 is required): $*" >&2
    exit 1
  fi

  counter_file="$MOCK_STATE_DIR/timeline.count"
  called=0
  if [[ -f "$counter_file" ]]; then
    called="$(cat "$counter_file")"
  fi
  call=$((called + 1))
  echo "$call" >"$counter_file"

  if [[ " $MOCK_API_FAIL_CALLS " == *" $call "* || "$MOCK_API_FAIL_CALLS" == all ]]; then
    echo "mocked gh api failure (call $call)" >&2
    exit 1
  fi

  while [[ ! -f "$MOCK_STATE_DIR/timeline.$call.page1" && "$call" -gt 1 ]]; do
    call=$((call - 1))
  done
  if [[ ! -f "$MOCK_STATE_DIR/timeline.$call.page1" ]]; then
    echo "[]" >"$MOCK_STATE_DIR/timeline.$call.page1"
  fi

  jq_expr=""
  prev=""
  for arg in "$@"; do
    if [[ "$prev" == "--jq" ]]; then
      jq_expr="$arg"
      break
    fi
    prev="$arg"
  done
  if [[ -z "$jq_expr" ]]; then
    echo "unexpected gh api args (--jq not found): $*" >&2
    exit 1
  fi

  # gh の --jq はページごとに適用されるため、モックも同じようにページごとに通す
  for page in "$MOCK_STATE_DIR/timeline.$call.page"*; do
    jq -r "$jq_expr" "$page"
  done
  exit 0
fi

if [[ "$1" == "pr" && "$2" == "view" && "$*" == *number* ]]; then
  printf '%s\\n' "$MOCK_PR_NUMBER"
  exit 0
fi

echo "unexpected gh args: $*" >&2
exit 1
`;

// 要求された待ち時間を記録したうえで、その秒数だけ実際に待つ。
// 経過時間の進み方を本番と揃えるため。クランプが外れてもテストがハングしないよう、
// 待ち時間には上限を設ける
const SLEEP_MOCK = `#!/usr/bin/env bash
set -eo pipefail

printf '%s\\n' "$1" >>"$SLEEP_LOG"
seconds="$1"
if [[ "$seconds" -gt 5 ]]; then
  seconds=5
fi
/bin/sleep "$seconds"
`;

interface Fixture {
  /** 呼び出しごと、ページごとの timeline イベント */
  calls?: TimelineEvent[][][];
  /** gh api を失敗させる呼び出し回数（"all" で常に失敗） */
  failCalls?: string;
  /** gh pr view が返す PR 番号 */
  prNumber?: string;
}

interface Result {
  code: number;
  stdout: string;
  stderr: string;
  /** スクリプトが要求した待ち時間の列 */
  sleeps: string[];
}

async function createFixture({ calls = [], failCalls = "", prNumber = "4242" }: Fixture): Promise<string> {
  const root = await mkdtemp(join(tmpdir(), "wait-for-review-"));
  const mockDir = join(root, "mocks");
  const stateDir = join(root, "state");
  await Promise.all([mkdir(mockDir), mkdir(stateDir)]);

  for (const [callIndex, pages] of calls.entries()) {
    for (const [pageIndex, events] of pages.entries()) {
      await writeFile(join(stateDir, `timeline.${callIndex + 1}.page${pageIndex + 1}`), JSON.stringify(events));
    }
  }

  await writeFile(join(root, "env"), JSON.stringify({ failCalls, prNumber }));
  await Promise.all([
    writeFile(join(mockDir, "gh"), GH_MOCK, { mode: 0o755 }),
    writeFile(join(mockDir, "sleep"), SLEEP_MOCK, { mode: 0o755 }),
  ]);
  await Promise.all([chmod(join(mockDir, "gh"), 0o755), chmod(join(mockDir, "sleep"), 0o755)]);

  return root;
}

async function runScript(root: string, args: string[] = ["--pr", "100", "--poll-interval", "1", "--timeout", "2"]) {
  const { failCalls, prNumber } = JSON.parse(await readFile(join(root, "env"), "utf8"));
  const sleepLog = join(root, "state/sleep.log");
  await writeFile(sleepLog, "");

  const result = spawnSync("bash", [scriptPath, ...args], {
    env: {
      PATH: `${join(root, "mocks")}:${process.env.PATH ?? "/usr/bin:/bin"}`,
      MOCK_STATE_DIR: join(root, "state"),
      MOCK_API_FAIL_CALLS: failCalls,
      MOCK_PR_NUMBER: prNumber,
      SLEEP_LOG: sleepLog,
    },
    encoding: "utf8",
  });
  if (result.error) throw result.error;

  const sleeps = (await readFile(sleepLog, "utf8")).split("\n").filter(Boolean);
  return { code: result.status ?? 1, stdout: result.stdout, stderr: result.stderr, sleeps } satisfies Result;
}

async function withFixture(fixture: Fixture, run: (root: string) => Promise<void>): Promise<void> {
  const root = await createFixture(fixture);
  try {
    await run(root);
  } finally {
    await rm(root, { recursive: true });
  }
}

test("wait-for-review", async (t) => {
  await t.test("reports REVIEWED once a review lands after the request", async () => {
    await withFixture(
      { calls: [[[request(REQUESTED_AT)]], [[request(REQUESTED_AT), review(REVIEWED_AT)]]] },
      async (root) => {
        const result = await runScript(root);
        assert.equal(result.code, 0);
        assert.match(result.stdout, /^REVIEWED: /m);
      },
    );
  });

  await t.test("reports REVIEWED without waiting when a review already exists", async () => {
    await withFixture({ calls: [[[request(REQUESTED_AT), review(REVIEWED_AT)]]] }, async (root) => {
      const result = await runScript(root);
      assert.equal(result.code, 0);
      assert.deepEqual(result.sleeps, []);
    });
  });

  await t.test("keeps waiting when the request is newer than the last review", async () => {
    await withFixture({ calls: [[[review(REVIEWED_AT), request(LATER_AT)]]] }, async (root) => {
      const result = await runScript(root);
      assert.equal(result.code, 1);
      assert.match(result.stdout, /^TIMEOUT: /m);
    });
  });

  await t.test("reports NOT_REQUESTED when the PR has no request for Copilot", async () => {
    await withFixture({ calls: [[[unrelated()]]] }, async (root) => {
      const result = await runScript(root);
      assert.equal(result.code, 1);
      assert.match(result.stdout, /^NOT_REQUESTED: /m);
      assert.deepEqual(result.sleeps, []);
    });
  });

  await t.test("reports NOT_REQUESTED when only a review exists", async () => {
    await withFixture({ calls: [[[review(REVIEWED_AT)]]] }, async (root) => {
      const result = await runScript(root);
      assert.equal(result.code, 1);
      assert.match(result.stdout, /^NOT_REQUESTED: /m);
    });
  });

  await t.test("reports TIMEOUT when no review arrives within the limit", async () => {
    await withFixture({ calls: [[[request(REQUESTED_AT)]]] }, async (root) => {
      const result = await runScript(root);
      assert.equal(result.code, 1);
      assert.match(result.stdout, /^TIMEOUT: 2 秒待ちましたが/m);
    });
  });

  await t.test("does not treat a request for another reviewer as one for Copilot", async () => {
    await withFixture({ calls: [[[request(REQUESTED_AT, "octocat")]]] }, async (root) => {
      const result = await runScript(root);
      assert.match(result.stdout, /^NOT_REQUESTED: /m);
    });
  });

  await t.test("does not treat a review by another reviewer as one by Copilot", async () => {
    await withFixture({ calls: [[[request(REQUESTED_AT), review(LATER_AT, "octocat")]]] }, async (root) => {
      const result = await runScript(root);
      assert.match(result.stdout, /^TIMEOUT: /m);
    });
  });

  await t.test("finds a request and a review that span multiple pages", async () => {
    await withFixture({ calls: [[[unrelated()], [request(REQUESTED_AT), review(REVIEWED_AT)]]] }, async (root) => {
      const result = await runScript(root);
      assert.equal(result.code, 0);
      assert.match(result.stdout, /^REVIEWED: /m);
    });
  });

  await t.test("ignores timeline events other than requests and reviews", async () => {
    const events = [unrelated(), request(REQUESTED_AT), unrelated(), review(REVIEWED_AT)];
    await withFixture({ calls: [[events]] }, async (root) => {
      const result = await runScript(root);
      assert.equal(result.code, 0);
      assert.match(result.stdout, /^REVIEWED: /m);
    });
  });

  await t.test("retries after a transient API failure", async () => {
    await withFixture({ calls: [[[request(REQUESTED_AT), review(REVIEWED_AT)]]], failCalls: "1" }, async (root) => {
      const result = await runScript(root);
      assert.equal(result.code, 0);
      assert.match(result.stdout, /^REVIEWED: /m);
      assert.match(result.stderr, /timeline API の取得に失敗しました（連続 1 回）/);
    });
  });

  await t.test("reports ERROR when the API keeps failing until the limit", async () => {
    await withFixture({ calls: [[[request(REQUESTED_AT)]]], failCalls: "all" }, async (root) => {
      const result = await runScript(root);
      assert.equal(result.code, 1);
      assert.match(result.stdout, /^ERROR: /m);
    });
  });

  await t.test("falls back to the PR of the current branch when --pr is omitted", async () => {
    await withFixture({ calls: [[[unrelated()]]], prNumber: "4242" }, async (root) => {
      const result = await runScript(root, ["--poll-interval", "1", "--timeout", "2"]);
      assert.match(result.stdout, /^NOT_REQUESTED: PR #4242 /m);
    });
  });

  await t.test("waits only the remaining time when it is shorter than the poll interval", async () => {
    await withFixture({ calls: [[[request(REQUESTED_AT)]]] }, async (root) => {
      const result = await runScript(root, ["--pr", "100", "--poll-interval", "2", "--timeout", "3"]);
      assert.deepEqual(result.sleeps, ["2", "1"]);
    });
  });

  await t.test("prints the completion rules with --help", async () => {
    await withFixture({}, async (root) => {
      for (const flag of ["--help", "-h"]) {
        const result = await runScript(root, [flag]);
        assert.equal(result.code, 0);
        assert.match(result.stdout, /REVIEWED（exit 0）/);
      }
    });
  });

  await t.test("rejects arguments it cannot act on", async () => {
    const invalid = [
      ["--unknown"],
      ["--pr"],
      ["--pr", "0"],
      ["--pr", "x"],
      ["--timeout", "1.5"],
      ["--poll-interval", "0"],
    ];
    await withFixture({}, async (root) => {
      for (const args of invalid) {
        const result = await runScript(root, args);
        assert.equal(result.code, 1, `expected a failure for: ${args.join(" ")}`);
        assert.match(result.stderr, /^error: /m);
      }
    });
  });
});
