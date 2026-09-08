import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { chmodSync, existsSync, mkdirSync, mkdtempSync, rmSync, symlinkSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const repositoryRoot = join(dirname(fileURLToPath(import.meta.url)), "..");
const scriptPath = join(repositoryRoot, "home/.config/git/filters/claude-settings.sh");
const gitConfigPath = join(repositoryRoot, "home/.config/git/config");
const portableCommand = 'bash "$HOME/.claude/hooks/herdr-agent-state.sh" session';

function localCommand(home: string): string {
  const path = `${home}/.claude/hooks/herdr-agent-state.sh`.replaceAll("'", `'"'"'`);
  return `bash '${path}' session`;
}

function invoke(mode: "clean" | "smudge", input: string, home = "/Users/example") {
  return spawnSync("bash", [scriptPath, mode], {
    encoding: "utf8",
    env: { ...process.env, HOME: home },
    input,
  });
}

function run(mode: "clean" | "smudge", input: object, home = "/Users/example"): object {
  const result = invoke(mode, JSON.stringify(input), home);
  if (result.error) throw result.error;
  assert.equal(result.status, 0, result.stderr);
  return JSON.parse(result.stdout);
}

test("normalizes and restores the Herdr Claude hook path", () => {
  const absoluteCommand = localCommand("/Users/example");
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

test("retains the existing JSON sort normalization", () => {
  const cleaned = run("clean", { z: true, values: ["z", "a"], a: true });

  assert.deepEqual(Object.keys(cleaned), ["a", "values", "z"]);
  assert.deepEqual(cleaned.values, ["a", "z"]);
});

test("quotes apostrophes in the local hook path", () => {
  const home = "/Users/O'Neil";
  const smudged = run("smudge", { command: portableCommand }, home);

  assert.equal(smudged.command, localCommand(home));
  assert.equal(run("clean", smudged, home).command, portableCommand);
});

test("is idempotent across repeated clean and smudge operations", () => {
  const portable = { command: portableCommand, values: ["z", "a"] };
  const cleaned = run("clean", portable);
  const smudged = run("smudge", cleaned);

  assert.deepEqual(run("clean", cleaned), cleaned);
  assert.deepEqual(run("smudge", smudged), smudged);
  assert.deepEqual(run("clean", smudged), cleaned);
});

test("rejects unsupported Herdr hook paths", () => {
  const unsupported = invoke(
    "clean",
    JSON.stringify({ command: "bash '/Users/other/.claude/hooks/herdr-agent-state.sh' session" }),
  );
  assert.notEqual(unsupported.status, 0);
  assert.match(unsupported.stderr, /unsupported Herdr Claude hook command/);
});

test("accepts exactly one top-level JSON object", () => {
  for (const input of ["", " ", "not JSON", "{}{}", "{}\n{}", "[]", "null", '"value"']) {
    assert.notEqual(invoke("clean", input).status, 0, JSON.stringify(input));
    assert.notEqual(invoke("smudge", input).status, 0, JSON.stringify(input));
  }

  assert.deepEqual(run("clean", {}), {});
  assert.deepEqual(run("smudge", {}), {});
});

test("uses the trusted global filter and fails closed", () => {
  const temporaryDirectory = mkdtempSync(join(tmpdir(), "claude-settings-filter-"));
  const home = join(temporaryDirectory, "home O'Neil");
  const repository = join(temporaryDirectory, "untrusted-repository");
  const trustedFilterDirectory = join(home, ".config/git/filters");
  const maliciousScriptDirectory = join(repository, "scripts");
  const maliciousMarker = join(repository, "malicious-filter-ran");
  const environment = {
    ...process.env,
    GIT_CONFIG_GLOBAL: gitConfigPath,
    GIT_CONFIG_NOSYSTEM: "1",
    HOME: home,
    XDG_CONFIG_HOME: join(home, ".config"),
  };

  try {
    mkdirSync(trustedFilterDirectory, { recursive: true });
    mkdirSync(maliciousScriptDirectory, { recursive: true });
    symlinkSync(scriptPath, join(trustedFilterDirectory, "claude-settings.sh"));
    writeFileSync(
      join(maliciousScriptDirectory, "git-filter-claude-settings.sh"),
      `#!/bin/sh\ntouch '${maliciousMarker}'\ncat\n`,
    );
    chmodSync(join(maliciousScriptDirectory, "git-filter-claude-settings.sh"), 0o755);

    assert.equal(spawnSync("git", ["init", "--quiet", repository], { env: environment }).status, 0);
    writeFileSync(join(repository, ".gitattributes"), "settings.json filter=pchan-dotfiles-claude-settings-v1\n");
    writeFileSync(join(repository, "settings.json"), JSON.stringify({ values: ["z", "a"], command: portableCommand }));

    const added = spawnSync("git", ["-C", repository, "add", ".gitattributes", "settings.json"], {
      encoding: "utf8",
      env: environment,
    });
    assert.equal(added.status, 0, added.stderr);
    assert.equal(existsSync(maliciousMarker), false);

    const indexedBeforeFailure = spawnSync("git", ["-C", repository, "show", ":settings.json"], {
      encoding: "utf8",
      env: environment,
    }).stdout;
    assert.deepEqual(JSON.parse(indexedBeforeFailure).values, ["a", "z"]);

    writeFileSync(
      join(repository, "settings.json"),
      JSON.stringify({ command: "bash '/Users/other/.claude/hooks/herdr-agent-state.sh' session" }),
    );
    const rejected = spawnSync("git", ["-C", repository, "add", "settings.json"], {
      encoding: "utf8",
      env: environment,
    });
    assert.notEqual(rejected.status, 0);

    const indexedAfterFailure = spawnSync("git", ["-C", repository, "show", ":settings.json"], {
      encoding: "utf8",
      env: environment,
    }).stdout;
    assert.equal(indexedAfterFailure, indexedBeforeFailure);
  } finally {
    rmSync(temporaryDirectory, { force: true, recursive: true });
  }
});
