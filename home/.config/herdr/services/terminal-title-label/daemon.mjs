import { spawn } from "node:child_process";
import { homedir } from "node:os";
import { join } from "node:path";
import { createConnection } from "node:net";

const socketPath = process.env.HERDR_SOCKET_PATH ?? join(homedir(), ".config", "herdr", "herdr.sock");
const reconnectDelay = 1_000;
const snapshotInterval = Number(process.env.HERDR_SNAPSHOT_INTERVAL_MS) || 1_000;
const snapshotTimeout = 5_000;

let reconnectTimer;
let snapshotInProgress = false;
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
  if (!agent || !paneId) return;

  const desiredLabel = title?.trim() || null;
  if (desiredLabel === label) {
    if (pendingTitles.get(paneId) === desiredLabel) pendingTitles.delete(paneId);
    return;
  }
  if (pendingTitles.get(paneId) === desiredLabel) return;

  pendingTitles.set(paneId, desiredLabel);
  const args = ["pane", "rename", paneId];
  if (desiredLabel) args.push(desiredLabel === "--clear" ? ` ${desiredLabel}` : desiredLabel);
  else args.push("--clear");
  const child = spawn("herdr", args, { stdio: "ignore" });
  const clearPendingTitle = () => {
    if (pendingTitles.get(paneId) === desiredLabel) pendingTitles.delete(paneId);
  };
  child.once("error", clearPendingTitle);
  child.once("exit", clearPendingTitle);
  child.unref();
}

function synchronizeSnapshot() {
  if (snapshotInProgress) return;
  snapshotInProgress = true;

  const socket = createConnection(socketPath);
  socket.setEncoding("utf8");
  let buffer = "";
  let complete = false;
  const finish = () => {
    if (complete) return;
    complete = true;
    clearTimeout(timeout);
    snapshotInProgress = false;
  };
  const timeout = setTimeout(() => socket.destroy(), snapshotTimeout);

  socket.on("connect", () => {
    socket.write(
      `${JSON.stringify({ id: "terminal-title-label-snapshot", method: "session.snapshot", params: {} })}\n`,
    );
  });
  socket.on("data", (chunk) => {
    buffer += chunk;
    const lines = buffer.split("\n");
    buffer = lines.pop();

    for (const line of lines) {
      try {
        const message = JSON.parse(line);
        if (message.id !== "terminal-title-label-snapshot") continue;

        for (const pane of message.result?.snapshot?.panes ?? []) renamePane(pane);
        socket.end();
      } catch {
        // A malformed snapshot should not stop later synchronization.
      }
    }
  });
  socket.on("error", finish);
  socket.on("close", finish);
}

function connect() {
  const socket = createConnection(socketPath);
  socket.setEncoding("utf8");
  let buffer = "";
  let closed = false;

  const subscriptionId = "terminal-title-label-subscription";
  let snapshotTimer;

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
          snapshotTimer = setInterval(synchronizeSnapshot, snapshotInterval);
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
    clearInterval(snapshotTimer);
    scheduleReconnect();
  });
}

connect();
