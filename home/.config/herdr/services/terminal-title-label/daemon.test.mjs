import assert from "node:assert/strict";
import { chmod, mkdir, mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { createServer } from "node:net";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { spawn } from "node:child_process";
import test from "node:test";
import { fileURLToPath } from "node:url";

const daemonPath = join(dirname(fileURLToPath(import.meta.url)), "daemon.mjs");

async function writeExecutable(path, content) {
  await writeFile(path, content);
  await chmod(path, 0o755);
}

function writeUtf8Split(socket, message) {
  const output = Buffer.from(`${message}\n`);
  const marker = output.indexOf(Buffer.from("認"));
  const split = marker === -1 ? 0 : marker + 1;
  socket.write(output.subarray(0, split));
  socket.write(output.subarray(split));
}

function waitFor(condition, timeout = 2_000) {
  const deadline = Date.now() + timeout;

  return new Promise((resolve, reject) => {
    const check = async () => {
      if (await condition()) return resolve();
      if (Date.now() >= deadline) return reject(new Error("timed out waiting for condition"));
      setTimeout(check, 10);
    };
    void check();
  });
}

test("mirrors agent terminal titles from pane updates", async () => {
  const root = await mkdtemp(join(tmpdir(), "terminal-title-label-"));
  const socketPath = join(root, "herdr.sock");
  const bin = join(root, "bin");
  const log = join(root, "herdr.log");
  const server = createServer();
  let daemon;

  try {
    await mkdir(bin);
    await writeFile(log, "");
    await writeExecutable(
      join(bin, "herdr"),
      `#!/usr/bin/env node
import { appendFileSync } from "node:fs";

appendFileSync(process.env.HERDR_LOG, process.argv.slice(2).join(" ") + "\\n");
`,
    );
    await new Promise((resolve, reject) => {
      server.once("error", reject);
      server.listen(socketPath, resolve);
    });

    let snapshotCalls = 0;
    let subscriptionSocket;
    server.on("connection", (socket) => {
      let buffer = "";

      socket.on("data", (data) => {
        buffer += data;
        const lines = buffer.split("\n");
        buffer = lines.pop();

        for (const line of lines) {
          const request = JSON.parse(line);
          if (request.method === "events.subscribe") {
            subscriptionSocket = socket;
            assert.deepEqual(request.params.subscriptions, [{ type: "pane.updated" }]);
            socket.write(`${JSON.stringify({ id: request.id, result: { type: "events_subscribed" } })}\n`);
            writeUtf8Split(
              socket,
              JSON.stringify({
                event: "pane.updated",
                data: {
                  type: "pane_updated",
                  pane: {
                    agent: "opencode",
                    label: "OpenCode",
                    pane_id: "w1:p2",
                    terminal_title: "認証タイトルを同期",
                  },
                },
              }),
            );
            writeUtf8Split(
              socket,
              JSON.stringify({
                event: "pane.updated",
                data: {
                  type: "pane_updated",
                  pane: {
                    agent: "opencode",
                    label: "認証タイトルを同期",
                    pane_id: "w1:p2",
                    terminal_title: null,
                  },
                },
              }),
            );
          }
          if (request.method === "session.snapshot") {
            assert.notStrictEqual(socket, subscriptionSocket);
            const snapshotIndex = snapshotCalls++;
            const title = snapshotIndex === 0 ? "⠋ 認証をリファクタリング" : "⠙ 認証をリファクタリング";
            const label = snapshotIndex === 0 ? "Claude" : snapshotIndex === 1 ? "手動ラベル" : title;
            writeUtf8Split(
              socket,
              JSON.stringify({
                id: request.id,
                result: {
                  snapshot: {
                    panes: [
                      {
                        agent: "claude",
                        label,
                        pane_id: "w1:p1",
                        terminal_title: title,
                      },
                    ],
                  },
                },
              }),
            );
          }
        }
      });
    });

    daemon = spawn(process.execPath, [daemonPath], {
      env: {
        ...process.env,
        HERDR_LOG: log,
        HERDR_SOCKET_PATH: socketPath,
        HERDR_SNAPSHOT_INTERVAL_MS: "10",
        PATH: `${bin}:${process.env.PATH}`,
      },
    });

    await waitFor(async () => {
      const output = await readFile(log, "utf8");
      return (
        output.includes("pane rename w1:p1 ⠋ 認証をリファクタリング\n") &&
        output.includes("pane rename w1:p1 ⠙ 認証をリファクタリング\n") &&
        output.includes("pane rename w1:p2 認証タイトルを同期\n") &&
        output.includes("pane rename w1:p2 --clear\n")
      );
    });
  } finally {
    daemon?.kill();
    await new Promise((resolve) => server.close(() => resolve()));
    await rm(root, { recursive: true, force: true });
  }
});
