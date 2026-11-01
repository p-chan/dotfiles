import assert from "node:assert/strict";
import { spawn, spawnSync } from "node:child_process";
import { appendFile, mkdtemp, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import test from "node:test";
import { setTimeout as sleep } from "node:timers/promises";
import { fileURLToPath } from "node:url";

const hookPath = join(dirname(fileURLToPath(import.meta.url)), "personal-require-japanese.ts");

const ENGLISH = "I updated the configuration file and verified that all of the tests pass successfully.";
const ENGLISH_REPORT =
  "I checked the settings file first.\nNext I will update the hook registration and run the tests.";
const JAPANESE = "設定ファイルを更新し、すべてのテストが通ることを確認しました。";

type Entry = Record<string, unknown>;

const user = (text: string): Entry => ({ type: "user", message: { role: "user", content: text } });
const text = (value: string, extra: Entry = {}): Entry => ({
  type: "assistant",
  ...extra,
  message: { role: "assistant", content: [{ type: "text", text: value }] },
});
const thinking = (value: string, extra: Entry = {}): Entry => ({
  type: "assistant",
  ...extra,
  message: { role: "assistant", content: [{ type: "thinking", thinking: value }] },
});
const toolUse = (id: string): Entry => ({
  type: "assistant",
  message: { role: "assistant", content: [{ type: "tool_use", id, name: "Bash", input: { command: "ls" } }] },
});
const toolResult = (id: string): Entry => ({
  type: "user",
  message: { role: "user", content: [{ type: "tool_result", tool_use_id: id, content: "ok" }] },
});

const jsonl = (entries: Entry[]) => entries.map((entry) => `${JSON.stringify(entry)}\n`).join("");

async function withTranscript(content: string, fn: (path: string) => Promise<void>): Promise<void> {
  const dir = await mkdtemp(join(tmpdir(), "require-japanese-"));
  const path = join(dir, "transcript.jsonl");
  try {
    await writeFile(path, content);
    await fn(path);
  } finally {
    await rm(dir, { recursive: true, force: true });
  }
}

function runHook(stdin: string, ...args: string[]): { status: number | null; stdout: string } {
  const result = spawnSync(hookPath, args, { input: stdin, encoding: "utf8" });
  if (result.error) throw result.error;
  return { status: result.status, stdout: result.stdout };
}

function stop(transcriptPath: string, lastAssistantMessage?: string, extra: Entry = {}): unknown {
  const input = {
    hook_event_name: "Stop",
    transcript_path: transcriptPath,
    stop_hook_active: false,
    ...(lastAssistantMessage === undefined ? {} : { last_assistant_message: lastAssistantMessage }),
    ...extra,
  };
  const { status, stdout } = runHook(JSON.stringify(input));
  assert.equal(status, 0);
  return stdout.trim() === "" ? null : JSON.parse(stdout);
}

// transcript の最後を最終回答にして Stop を呼ぶ
async function stopWith(entries: Entry[], final: string): Promise<{ decision?: string; reason?: string } | null> {
  let output: unknown = null;
  await withTranscript(jsonl([...entries, text(final)]), async (path) => {
    output = stop(path, final);
  });
  return output;
}

test("英語主体の最終回答を差し戻し、英語の箇所だけを書き直させる", async () => {
  const output = await stopWith([user("やって")], ENGLISH);
  assert.equal(output?.decision, "block");
  assert.match(output?.reason ?? "", /最終回答: I updated the configuration/);
  assert.match(output?.reason ?? "", /これらの箇所だけを日本語で書き直して/);
  assert.match(output?.reason ?? "", /日本語で書けていた部分は繰り返さない/);
});

test("日本語の最終回答は通す", async () => {
  assert.equal(await stopWith([user("やって")], JAPANESE), null);
});

test("英語の識別子が混ざった日本語は通す", async () => {
  assert.equal(
    await stopWith([user("やって")], "README の Herdr の Claude 連携の節に、Stop hook の設定方法を追記しました。"),
    null,
  );
});

test("一言程度の短い英語の返事は通す", async () => {
  assert.equal(await stopWith([user("やって")], "OK, done."), null);
});

for (const [name, body] of [
  ["コードブロック", "次のコマンドを実行します。\n\n```sh\n" + `echo "${ENGLISH} ${ENGLISH}"` + "\n```"],
  ["チルダのコードブロック", "下書きです。\n\n~~~\n" + ENGLISH + "\n" + ENGLISH + "\n~~~"],
  ["インラインコード", "`" + ENGLISH + "` を実行します。"],
  ["URL", "参照: https://example.com/this-is-a-very-long-english-path/about-configuration-and-tests"],
  ["メールアドレス", "連絡先は very.long.english.address.for.testing@example-company-domain.com です。"],
  ["Markdown のリンク", `[${ENGLISH}](https://example.com) を見てください。`],
] as const) {
  test(`${name}は数える前に取り除く`, async () => {
    assert.equal(await stopWith([user("やって")], body), null);
  });
}

test("取り除いたあとの本文が英語なら差し戻す", async () => {
  const output = await stopWith([user("やって")], "`ls` " + ENGLISH);
  assert.equal(output?.decision, "block");
});

test("stop_hook_active が true のときは何もしない", async () => {
  await withTranscript(jsonl([user("やって"), text(ENGLISH)]), async (path) => {
    assert.equal(stop(path, ENGLISH, { stop_hook_active: true }), null);
  });
});

test("複数行の英語の途中報告を差し戻す", async () => {
  const output = await stopWith([user("やって"), text(ENGLISH_REPORT), toolUse("t1"), toolResult("t1")], JAPANESE);
  assert.equal(output?.decision, "block");
  assert.match(output?.reason ?? "", /途中報告: I checked the settings/);
  assert.doesNotMatch(output?.reason ?? "", /最終回答/);
});

test("長い 1 段落の英語の途中報告を差し戻す", async () => {
  const paragraph = Array.from({ length: 4 }, () => ENGLISH).join(" ");
  const output = await stopWith([user("やって"), text(paragraph), toolUse("t1"), toolResult("t1")], JAPANESE);
  assert.equal(output?.decision, "block");
});

test("ツールを呼ぶ前の 1 行程度の英語の前置きは見逃す", async () => {
  const output = await stopWith(
    [user("やって"), text("Let me check the settings file first."), toolUse("t1"), toolResult("t1")],
    JAPANESE,
  );
  assert.equal(output, null);
});

test("直近のユーザー入力より前の英語は見ない", async () => {
  const output = await stopWith(
    [user("前の依頼"), text(ENGLISH_REPORT), toolUse("t1"), toolResult("t1"), text(ENGLISH), user("次の依頼")],
    JAPANESE,
  );
  assert.equal(output, null);
});

test("ツール結果とメタ情報はユーザー入力として扱わない", async () => {
  const output = await stopWith(
    [
      user("やって"),
      text(ENGLISH_REPORT),
      toolUse("t1"),
      toolResult("t1"),
      { type: "user", isMeta: true, message: { role: "user", content: "メタ情報" } },
    ],
    JAPANESE,
  );
  assert.equal(output?.decision, "block");
});

test("thinkingDisplay が updates の thinking を見る", async () => {
  const output = await stopWith(
    [user("やって"), thinking(ENGLISH_REPORT, { thinkingDisplay: "updates" }), toolUse("t1"), toolResult("t1")],
    JAPANESE,
  );
  assert.equal(output?.decision, "block");
  assert.match(output?.reason ?? "", /thinking: I checked/);
});

test("thinkingDisplay が updates でない thinking は見ない", async () => {
  const output = await stopWith([user("やって"), thinking(ENGLISH_REPORT), toolUse("t1"), toolResult("t1")], JAPANESE);
  assert.equal(output, null);
});

test("最終回答が遅れて書き込まれても、追記を待って途中報告を見る", async () => {
  await withTranscript(jsonl([user("やって")]), async (path) => {
    const child = spawn(hookPath, [], { stdio: ["pipe", "pipe", "inherit"] });
    let stdout = "";
    child.stdout.on("data", (chunk) => (stdout += chunk));
    const exited = new Promise((resolve) => child.on("close", resolve));
    child.stdin.end(
      JSON.stringify({
        hook_event_name: "Stop",
        transcript_path: path,
        stop_hook_active: false,
        last_assistant_message: JAPANESE,
      }),
    );

    await sleep(150);
    await appendFile(path, jsonl([text(ENGLISH_REPORT), toolUse("t1"), toolResult("t1"), text(JAPANESE)]));

    assert.equal(await exited, 0);
    assert.equal(JSON.parse(stdout).decision, "block");
  });
});

test("last_assistant_message だけで英語と判定できたときは待たない", async () => {
  await withTranscript(jsonl([user("やって")]), async (path) => {
    const started = Date.now();
    const output = stop(path, ENGLISH) as { decision: string };
    assert.equal(output.decision, "block");
    assert.ok(Date.now() - started < 300, "transcript の書き込みを待っていない");
  });
});

test("last_assistant_message がなければ transcript の最後の本文を最終回答として見る", async () => {
  await withTranscript(jsonl([user("やって"), text(ENGLISH)]), async (path) => {
    assert.equal((stop(path) as { decision: string }).decision, "block");
  });
});

test("壊れた行は読み飛ばす", async () => {
  await withTranscript(
    `{broken\n${jsonl([user("やって"), text(ENGLISH_REPORT), toolUse("t1"), toolResult("t1")])}{"type":\n${jsonl([text(JAPANESE)])}`,
    async (path) => {
      assert.equal((stop(path, JAPANESE) as { decision: string }).decision, "block");
    },
  );
});

test("読めない transcript でもエラー終了しない", () => {
  const { status, stdout } = runHook(
    JSON.stringify({
      hook_event_name: "Stop",
      transcript_path: "/nonexistent/transcript.jsonl",
      last_assistant_message: JAPANESE,
    }),
  );
  assert.equal(status, 0);
  assert.equal(stdout, "");
});

test("入力が空でも何もせずに正常終了する", () => {
  assert.deepEqual(runHook(""), { status: 0, stdout: "" });
  assert.deepEqual(runHook("not json"), { status: 0, stdout: "" });
});

test("--check で過去の記録のうち英語と判定した箇所を表示する", async () => {
  const entries = [
    user("最初の依頼"),
    text(ENGLISH),
    user("次の依頼"),
    text(ENGLISH_REPORT),
    toolUse("t1"),
    toolResult("t1"),
    text(JAPANESE),
  ];
  await withTranscript(jsonl(entries), async (path) => {
    const { status, stdout } = runHook("", "--check", path);
    assert.equal(status, 0);
    assert.match(stdout, /ターン 1: 最初の依頼\n {2}- 最終回答: I updated/);
    assert.match(stdout, /ターン 2: 次の依頼\n {2}- 途中報告: I checked/);
    assert.match(stdout, /英語と判定した箇所: 2 件/);
  });
});
