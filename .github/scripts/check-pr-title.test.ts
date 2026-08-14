import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";
import test from "node:test";
import { checkTitle } from "./check-pr-title.ts";

const scriptPath = fileURLToPath(new URL("./check-pr-title.ts", import.meta.url));

function runCLI(args: string[]): { code: number; stdout: string; stderr: string } {
  const result = spawnSync(process.execPath, [scriptPath, ...args], { encoding: "utf8" });
  if (result.error) throw result.error;
  return {
    code: result.status ?? 1,
    stdout: result.stdout,
    stderr: result.stderr,
  };
}

test("Valid Angular-flavored Conventional Commits titles", async (t) => {
  const validTitles = [
    "feat: add new feature",
    "fix: resolve bug",
    "docs: update readme",
    "style: format code",
    "refactor: improve performance",
    "test: add unit tests",
    "build: update dependencies",
    "ci: add workflow",
    "perf: optimize algorithm",
    "feat(router): add lazy loading",
    "fix(auth): handle token expiry",
    "docs(api): update endpoints",
    "feat: add `console.log` for debugging",
    "docs: update `README.md` file",
  ];

  for (const title of validTitles) {
    await t.test(`"${title}" should be valid`, () => {
      const result = checkTitle(title);

      assert.equal(result.valid, true, `Expected "${title}" to be valid`);
    });
  }
});

test("Invalid PR titles", async (t) => {
  const invalidTitles = [
    { title: "", expectedError: "Error: PR title is empty" },
    {
      title: "invalid: bad type",
      expectedError: "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    },
    {
      title: "Add new feature",
      expectedError: "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    },
    {
      title: "feat:",
      expectedError: "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    },
    {
      title: "feat: ",
      expectedError: "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    },
    {
      title: "feat:  ",
      expectedError: "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    },
    {
      title: "unknown: some change",
      expectedError: "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    },
    {
      title: "feat add new feature",
      expectedError: "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    },
    {
      title: "feat()",
      expectedError: "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    },
    {
      title: "FEAT: uppercase type",
      expectedError: "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    },
  ];

  for (const { title, expectedError } of invalidTitles) {
    await t.test(`"${title}" should be invalid`, () => {
      const result = checkTitle(title);

      assert.equal(result.valid, false, `Expected "${title}" to be invalid`);
      if (!result.valid) {
        assert.equal(result.error, expectedError, `Expected specific error for "${title}"`);
      }
    });
  }
});

test("Angular types are supported", async (t) => {
  const angularTypes = ["build", "chore", "ci", "docs", "feat", "fix", "perf", "refactor", "style", "test"];

  for (const type of angularTypes) {
    await t.test(`Type "${type}" should be supported`, () => {
      const result = checkTitle(`${type}: test change`);

      assert.equal(result.valid, true, `Type "${type}" should be valid`);
    });
  }
});

test("Scope variations", async (t) => {
  await t.test("No scope should be valid", () => {
    const result = checkTitle("feat: add feature");

    assert.equal(result.valid, true);
  });

  await t.test("Single word scope should be valid", () => {
    const result = checkTitle("feat(auth): add feature");

    assert.equal(result.valid, true);
  });

  await t.test("Multi-word scope should be valid", () => {
    const result = checkTitle("feat(user-auth): add feature");

    assert.equal(result.valid, true);
  });

  await t.test("Empty scope should be invalid", () => {
    const result = checkTitle("feat(): add feature");

    assert.equal(result.valid, false);
    if (!result.valid) {
      assert.equal(
        result.error,
        "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
      );
    }
  });
});

test("CLI Integration Tests", async (t) => {
  await t.test("Valid title should exit with code 0", () => {
    const { code, stdout, stderr } = runCLI(["feat: add new feature"]);

    assert.equal(code, 0);
    assert.equal(stdout.includes("PR title conforms to Angular-flavored Conventional Commits-like format"), true);
    assert.equal(stderr.trim(), "");
  });

  await t.test("Invalid title should exit with code 1", () => {
    const { code, stdout, stderr } = runCLI(["invalid title"]);

    assert.equal(code, 1);
    assert.equal(stderr.includes("Error:"), true);
    assert.equal(stdout.trim(), "");
  });

  await t.test("No arguments should exit with code 1", () => {
    const { code, stdout, stderr } = runCLI([]);

    assert.equal(code, 1);
    assert.equal(stderr.includes("Error: PR title is not specified"), true);
    assert.equal(stdout.trim(), "");
  });

  await t.test("--help should exit with code 0", () => {
    const { code, stdout, stderr } = runCLI(["--help"]);

    assert.equal(code, 0);
    assert.equal(stdout.includes("Usage:"), true);
    assert.equal(stdout.includes("Options:"), true);
    assert.equal(stderr.trim(), "");
  });

  await t.test("--version should exit with code 0", () => {
    const { code, stdout, stderr } = runCLI(["--version"]);

    assert.equal(code, 0);
    assert.equal(stdout.includes("check-pr-title 1.0.0"), true);
    assert.equal(stderr.trim(), "");
  });
});
