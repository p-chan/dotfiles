import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const repositoryRoot = join(dirname(fileURLToPath(import.meta.url)), "..");
const hookPath = join(repositoryRoot, "home/.claude/hooks/personal-sync-pr-after-push.sh");
const contextPath = join(repositoryRoot, "home/.claude/hooks/personal-sync-pr-after-push.md");
const settingsPath = join(repositoryRoot, "home/.claude/settings.json");

function runHook(command: string) {
  return spawnSync("bash", [hookPath], {
    encoding: "utf8",
    input: JSON.stringify({
      hook_event_name: "PostToolUse",
      tool_input: { command },
      tool_name: "Bash",
      tool_response: {
        stderr: "To github.com:acme/widget.git\n   1111111..2222222  feature -> feature\n",
        stdout: "",
      },
    }),
  });
}

test("returns the Markdown context for supported pushes", () => {
  const commands = [
    "git push",
    "git push --force-with-lease",
    "git push --force-with-lease=refs/heads/feature:1111111",
    "git push --force",
    "git push -f",
  ];

  for (const command of commands) {
    const result = runHook(command);
    assert.equal(result.status, 0, `${command}: ${result.stderr}`);
    const output = JSON.parse(result.stdout);
    assert.equal(output.hookSpecificOutput.hookEventName, "PostToolUse");
    assert.equal(output.hookSpecificOutput.additionalContext, readFileSync(contextPath, "utf8"));
  }
});

test("returns nothing for unsupported push forms and unrelated commands", () => {
  const commands = ["git push origin feature", "git push --all", "echo $(date)"];

  for (const command of commands) {
    const result = runHook(command);
    assert.equal(result.status, 0, `${command}: ${result.stderr}`);
    assert.equal(result.stdout, "", command);
  }
});

test("registers the hook for successful Bash tool calls", () => {
  const settings = JSON.parse(readFileSync(settingsPath, "utf8"));

  assert.deepEqual(settings.hooks.PostToolUse, [
    {
      hooks: [
        {
          command: 'bash "$HOME/.claude/hooks/personal-sync-pr-after-push.sh"',
          type: "command",
        },
      ],
      matcher: "Bash",
    },
  ]);
});
