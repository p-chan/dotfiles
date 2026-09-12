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
      `#!/bin/sh
if [ "$1" = api ] && [ "$2" = snapshot ]; then
  printf '%s\\n' "$HERDR_SNAPSHOT_JSON"
  exit 0
fi
printf '%s\\n' "$*" >> "$HERDR_LOG"
`,
    );
    await new Promise((resolve, reject) => {
      server.once("error", reject);
      server.listen(socketPath, resolve);
    });

    server.on("connection", (socket) => {
      let buffer = "";

      socket.on("data", (data) => {
        buffer += data;
        const lines = buffer.split("\n");
        buffer = lines.pop();

        for (const line of lines) {
          const request = JSON.parse(line);
          if (request.method === "events.subscribe") {
            assert.deepEqual(request.params.subscriptions, [{ type: "pane.updated" }]);
            socket.write(`${JSON.stringify({ id: request.id, result: { type: "events_subscribed" } })}\n`);
            socket.write(
              `${JSON.stringify({
                event: "pane.updated",
                data: {
                  type: "pane_updated",
                  pane: {
                    agent: "opencode",
                    label: "OpenCode",
                    pane_id: "w1:p2",
                    terminal_title: "Add title synchronization",
                  },
                },
              })}\n`,
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
        HERDR_SNAPSHOT_JSON: JSON.stringify({
          result: {
            snapshot: {
              panes: [
                {
                  agent: "claude",
                  label: "Claude",
                  pane_id: "w1:p1",
                  terminal_title: "Refactor authentication",
                },
              ],
            },
          },
        }),
        PATH: `${bin}:${process.env.PATH}`,
      },
    });

    await waitFor(async () => {
      const output = await readFile(log, "utf8");
      return (
        output.includes("pane rename w1:p1 Refactor authentication\n") &&
        output.includes("pane rename w1:p2 Add title synchronization\n")
      );
    });
  } finally {
    daemon?.kill();
    await new Promise((resolve) => server.close(() => resolve()));
    await rm(root, { recursive: true, force: true });
  }
});
