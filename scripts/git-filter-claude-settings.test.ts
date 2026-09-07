import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { dirname, join } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const scriptPath = join(dirname(fileURLToPath(import.meta.url)), "git-filter-claude-settings.sh");
const portableCommand = 'bash "$HOME/.claude/hooks/herdr-agent-state.sh" session';

function run(mode: "clean" | "smudge", input: object, home = "/Users/example"): object {
  const result = spawnSync("bash", [scriptPath, mode], {
    encoding: "utf8",
    env: { ...process.env, HOME: home },
    input: JSON.stringify(input),
  });
  if (result.error) throw result.error;
  assert.equal(result.status, 0, result.stderr);
  return JSON.parse(result.stdout);
}

test("normalizes and restores the Herdr Claude hook path", () => {
  const absoluteCommand = "bash '/Users/example/.claude/hooks/herdr-agent-state.sh' session";
  const settings = {
    hooks: {
      SessionStart: [
        {
          matcher: "*",
          hooks: [
            { type: "command", command: absoluteCommand, timeout: 10 },
            { type: "command", command: "echo keep-me" },
          ],
        },
      ],
    },
  };

  const cleaned = run("clean", settings);
  assert.equal(cleaned.hooks.SessionStart[0].hooks[0].command, portableCommand);
  assert.equal(cleaned.hooks.SessionStart[0].hooks[1].command, "echo keep-me");

  const smudged = run("smudge", cleaned);
  assert.equal(smudged.hooks.SessionStart[0].hooks[0].command, absoluteCommand);
  assert.equal(smudged.hooks.SessionStart[0].hooks[1].command, "echo keep-me");
});
