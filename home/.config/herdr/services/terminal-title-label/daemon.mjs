import { spawn } from "node:child_process";
import { homedir } from "node:os";
import { join } from "node:path";
import { createConnection } from "node:net";

const socketPath = process.env.HERDR_SOCKET_PATH ?? join(homedir(), ".config", "herdr", "herdr.sock");
const reconnectDelay = 1_000;

let reconnectTimer;
const pendingTitles = new Map();

function scheduleReconnect() {
  if (reconnectTimer) return;

  reconnectTimer = setTimeout(() => {
    reconnectTimer = undefined;
    connect();
  }, reconnectDelay);
}

function renamePane(pane) {
  const { agent, label, pane_id: paneId, terminal_title: title } = pane;
  if (!agent || !paneId || !title) return;
  if (title === label) {
    if (pendingTitles.get(paneId) === title) pendingTitles.delete(paneId);
    return;
  }
  if (pendingTitles.get(paneId) === title) return;

  pendingTitles.set(paneId, title);
  const child = spawn("herdr", ["pane", "rename", paneId, title], { stdio: "ignore" });
  child.once("error", () => {
    if (pendingTitles.get(paneId) === title) pendingTitles.delete(paneId);
  });
  child.once("exit", (code) => {
    if (code !== 0 && pendingTitles.get(paneId) === title) pendingTitles.delete(paneId);
  });
  child.unref();
}

function synchronizeSnapshot() {
  const child = spawn("herdr", ["api", "snapshot"], { stdio: ["ignore", "pipe", "ignore"] });
  let output = "";

  child.stdout.on("data", (chunk) => {
    output += chunk;
  });
  child.once("close", (code) => {
    if (code !== 0) return;

    try {
      for (const pane of JSON.parse(output).result?.snapshot?.panes ?? []) renamePane(pane);
    } catch {
      // Live pane updates continue when a snapshot is unavailable.
    }
  });
}

function connect() {
  const socket = createConnection(socketPath);
  let buffer = "";
  let closed = false;

  const subscriptionId = "terminal-title-label-subscription";

  socket.on("connect", () => {
    socket.write(
      `${JSON.stringify({
        id: subscriptionId,
        method: "events.subscribe",
        params: { subscriptions: [{ type: "pane.updated" }] },
      })}\n`,
    );
  });

  socket.on("data", (chunk) => {
    buffer += chunk;
    const lines = buffer.split("\n");
    buffer = lines.pop();

    for (const line of lines) {
      try {
        const message = JSON.parse(line);
        if (message.id === subscriptionId) {
          synchronizeSnapshot();
        }
        if (message.event === "pane.updated") renamePane(message.data?.pane);
      } catch {
        // A malformed message should not stop synchronization for later events.
      }
    }
  });

  socket.on("error", () => {});
  socket.on("close", () => {
    if (closed) return;
    closed = true;
    scheduleReconnect();
  });
}

connect();
