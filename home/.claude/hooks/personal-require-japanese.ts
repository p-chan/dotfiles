#!/usr/bin/env node
// Claude Code の応答が英語主体になっていたら、日本語で書き直させる hook。
// Stop で、最終回答、ツール呼び出しの間の途中報告、画面に出る thinking を検査する。
// `--check <transcript.jsonl>` を付けると、過去の記録のうち英語と判定した箇所を表示する。

import { readFileSync } from "node:fs";
import { setTimeout as sleep } from "node:timers/promises";

// 閾値は、手元の過去のセッション（123 件、約 2,900 か所の本文）の集計と、Stop hook の計測から決めた。

// 英語主体とみなす英字の最小数。1〜2 語の返事（「OK」「Done.」「Sounds good.」は 10 文字以下）を見逃し、
// 過去の記録で最も短い英語の最終回答（英字 19 文字）は捕まえる
const MIN_LATIN = 16;
// 英字が日本語の文字数の何倍を超えたら英語主体とみなすか。過去の記録では、日本語の本文は最大 4.4 倍
// （英語の部品名を並べた一覧など）、日本語が少し混ざった英語の本文は最小 12 倍だったので、その間のきりのいい値にする
const LATIN_TO_JAPANESE_RATIO = 8;
// 1 行の途中報告は、英字がこの数以上の長い段落だけを見る。過去の記録では、ツールを呼ぶ前の
// 1 行の前置き（189 件）は最大 138 文字、画面に出た thinking の段落は 164 文字と 236 文字だった
const MIN_LATIN_LONG_PARAGRAPH = 160;
// 最終回答が transcript に書き込まれるのを待つ上限と間隔。計測では、hook の起動時点では毎回まだ書き込まれておらず、
// 起動から 51〜71 ms 後に現れた
const TRANSCRIPT_WAIT_MS = 400;
const TRANSCRIPT_POLL_MS = 20;
// reason に挙げる箇所の数と、各箇所の冒頭の長さ
const MAX_EXCERPTS = 4;
const EXCERPT_LENGTH = 80;

type Kind = "最終回答" | "途中報告" | "thinking";

interface Finding {
  kind: Kind;
  text: string;
}

interface Entry {
  type?: string;
  isMeta?: boolean;
  isSidechain?: boolean;
  thinkingDisplay?: string;
  message?: { content?: unknown };
}

interface Block {
  type?: string;
  text?: string;
  thinking?: string;
}

interface Turn {
  intermediates: string[];
  thinkings: string[];
  // 最後のツール呼び出しより後の本文。まだなければ null
  trailing: string | null;
  // 最後のブロックが本文のときの、その本文
  lastText: string | null;
  // ユーザー入力の冒頭（--check の表示用）
  prompt: string;
}

// コードブロック、インラインコード、Markdown のリンク、URL、メールアドレスを取り除く
export function stripIgnored(text: string): string {
  return text
    .replace(/^[ \t]*(`{3,}|~{3,})[^\n]*\n[\s\S]*?(?:^[ \t]*\1[ \t]*$|$(?![\s\S]))/gm, "")
    .replace(/`+[^`\n]*`+/g, "")
    .replace(/!?\[[^\]\n]*\]\([^)\n]*\)/g, "")
    .replace(/<?https?:\/\/[^\s>)]+>?/g, "")
    .replace(/[\w.+-]+@[\w-]+(?:\.[\w-]+)+/g, "");
}

export function measure(text: string): { latin: number; japanese: number; lines: number } {
  const stripped = stripIgnored(text);
  return {
    latin: stripped.match(/[A-Za-z]/g)?.length ?? 0,
    japanese: stripped.match(/[\p{Script=Hiragana}\p{Script=Katakana}\p{Script=Han}]/gu)?.length ?? 0,
    lines: stripped.split("\n").filter((line) => line.trim() !== "").length,
  };
}

export function isEnglish(text: string): boolean {
  const { latin, japanese } = measure(text);
  return latin >= MIN_LATIN && latin > japanese * LATIN_TO_JAPANESE_RATIO;
}

// 途中報告は、画面で目立つ複数行のものと、1 行でも長い段落だけを見る
export function isEnglishReport(text: string): boolean {
  if (!isEnglish(text)) return false;
  const { latin, lines } = measure(text);
  return lines >= 2 || latin >= MIN_LATIN_LONG_PARAGRAPH;
}

function blocksOf(entry: Entry): Block[] {
  const content = entry.message?.content;
  if (typeof content === "string") return [{ type: "text", text: content }];
  return Array.isArray(content) ? content.filter((block) => block && typeof block === "object") : [];
}

function isUserInput(entry: Entry): boolean {
  if (entry.type !== "user" || entry.isMeta) return false;
  const blocks = blocksOf(entry);
  return blocks.length > 0 && !blocks.every((block) => block.type === "tool_result");
}

export function parseEntries(content: string): Entry[] {
  const entries: Entry[] = [];
  for (const line of content.split("\n")) {
    if (line.trim() === "") continue;
    try {
      const entry = JSON.parse(line);
      if (entry && typeof entry === "object" && !entry.isSidechain) entries.push(entry);
    } catch {
      // 書きかけや壊れた行は読み飛ばす
    }
  }
  return entries;
}

function analyzeTurn(entries: Entry[], prompt: string): Turn {
  const intermediates: string[] = [];
  const thinkings: string[] = [];
  let segment: string[] = [];
  let lastText: string | null = null;

  const closeSegment = () => {
    if (segment.length > 0) intermediates.push(segment.join("\n\n"));
    segment = [];
  };

  for (const entry of entries) {
    for (const block of blocksOf(entry)) {
      if (entry.type !== "assistant") continue;
      if (block.type === "text" && typeof block.text === "string" && block.text.trim() !== "") {
        segment.push(block.text);
        lastText = block.text;
      } else if (block.type === "thinking") {
        if (entry.thinkingDisplay === "updates" && block.thinking?.trim()) thinkings.push(block.thinking);
      } else if (block.type === "tool_use") {
        closeSegment();
        lastText = null;
      }
    }
  }

  return {
    intermediates,
    thinkings,
    trailing: segment.length > 0 ? segment.join("\n\n") : null,
    lastText,
    prompt,
  };
}

function promptOf(entry: Entry | undefined): string {
  if (!entry) return "";
  return blocksOf(entry)
    .map((block) => (block.type === "text" ? (block.text ?? "") : ""))
    .join(" ");
}

export function splitTurns(entries: Entry[]): Turn[] {
  const starts = entries.flatMap((entry, index) => (isUserInput(entry) ? [index] : []));
  if (starts[0] !== 0) starts.unshift(-1);
  return starts.map((start, i) =>
    analyzeTurn(entries.slice(start + 1, starts[i + 1] ?? entries.length), promptOf(entries[start])),
  );
}

function lastTurn(content: string): Turn {
  const turns = splitTurns(parseEntries(content));
  return turns[turns.length - 1];
}

// final が null のときは、transcript の最後の本文を最終回答として扱う
function findEnglish(turn: Turn, final: string | null): Finding[] {
  const findings: Finding[] = [];
  const finalText = final ?? turn.trailing;
  const reports = [...turn.intermediates];
  // 最終回答の書き込みが追いついていなければ、transcript の最後の本文は途中報告として見る
  if (final !== null && turn.trailing !== null && !isFinalWritten(turn, final)) reports.push(turn.trailing);

  if (finalText !== null && isEnglish(finalText)) findings.push({ kind: "最終回答", text: finalText });
  for (const text of reports) if (isEnglishReport(text)) findings.push({ kind: "途中報告", text });
  for (const text of turn.thinkings) if (isEnglishReport(text)) findings.push({ kind: "thinking", text });
  return findings;
}

function normalize(text: string): string {
  return text.replace(/\s+/g, " ").trim();
}

function isFinalWritten(turn: Turn, final: string): boolean {
  if (turn.lastText === null || turn.trailing === null) return false;
  const expected = normalize(final);
  if (expected === "") return true;
  return normalize(turn.trailing).includes(expected) || expected.includes(normalize(turn.lastText));
}

function readTranscript(path: unknown): string {
  if (typeof path !== "string" || path === "") return "";
  try {
    return readFileSync(path, "utf8");
  } catch {
    return "";
  }
}

// 最終回答が transcript に書き込まれるまで、上限つきで読み直して待つ
async function readTurn(path: unknown, final: string | null, wait: boolean): Promise<Turn> {
  const deadline = Date.now() + (wait ? TRANSCRIPT_WAIT_MS : 0);
  for (;;) {
    const turn = lastTurn(readTranscript(path));
    const written = final === null ? turn.lastText !== null : isFinalWritten(turn, final);
    if (written || Date.now() >= deadline) return turn;
    await sleep(TRANSCRIPT_POLL_MS);
  }
}

function excerpt(text: string): string {
  const line = text.replace(/\s+/g, " ").trim();
  return line.length > EXCERPT_LENGTH ? `${line.slice(0, EXCERPT_LENGTH)}…` : line;
}

function stopReason(findings: Finding[]): string {
  const items = findings.slice(0, MAX_EXCERPTS).map((finding) => `- ${finding.kind}: ${excerpt(finding.text)}`);
  if (findings.length > MAX_EXCERPTS) items.push(`- ほか ${findings.length - MAX_EXCERPTS} 件`);
  return [
    "応答に英語主体の箇所がありました。",
    ...items,
    "",
    "これらの箇所だけを日本語で書き直してください。日本語で書けていた部分は繰り返さないでください。コード、コマンド、英文の下書きなど、英語のままにする必要があるものはコードブロックに入れてください。",
  ].join("\n");
}

async function handleStop(input: Record<string, unknown>): Promise<unknown> {
  if (input.stop_hook_active === true) return null;
  const final = typeof input.last_assistant_message === "string" ? input.last_assistant_message : null;
  const finalIsEnglish = final !== null && isEnglish(final);
  const turn = await readTurn(input.transcript_path, final, !finalIsEnglish);
  const findings = findEnglish(turn, final);
  if (findings.length === 0) return null;
  return { decision: "block", reason: stopReason(findings) };
}

async function readStdin(): Promise<string> {
  const chunks: Buffer[] = [];
  for await (const chunk of process.stdin) chunks.push(chunk as Buffer);
  return Buffer.concat(chunks).toString("utf8");
}

function check(path: string): void {
  const turns = splitTurns(parseEntries(readTranscript(path)));
  let count = 0;
  turns.forEach((turn, index) => {
    const findings = findEnglish(turn, null);
    if (findings.length === 0) return;
    console.log(`ターン ${index + 1}: ${excerpt(turn.prompt)}`);
    for (const finding of findings) console.log(`  - ${finding.kind}: ${excerpt(finding.text)}`);
    count += findings.length;
  });
  console.log(`英語と判定した箇所: ${count} 件`);
}

async function main(): Promise<void> {
  const args = process.argv.slice(2);
  if (args[0] === "--check") {
    if (!args[1]) {
      console.error("使い方: personal-require-japanese.ts --check <transcript.jsonl>");
      process.exitCode = 1;
      return;
    }
    check(args[1]);
    return;
  }

  const raw = await readStdin();
  if (raw.trim() === "") return;
  const input = JSON.parse(raw);
  if (!input || typeof input !== "object") return;
  const output = input.hook_event_name === "Stop" ? await handleStop(input) : null;
  if (output) process.stdout.write(`${JSON.stringify(output)}\n`);
}

// 判定の関数をほかのスクリプトから import できるよう、直接実行されたときだけ動かす
if (import.meta.main) {
  try {
    await main();
  } catch {
    // hook の不具合でセッションを止めないよう、エラーでも正常終了する
  }
}
