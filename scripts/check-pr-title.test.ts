import { assertEquals } from "jsr:@std/assert@1.0.13";
import { checkTitle } from "./check-pr-title.ts";

async function runCLI(
  args: string[],
): Promise<{ code: number; stdout: string; stderr: string }> {
  const cmd = new Deno.Command("deno", {
    args: ["run", "-A", "scripts/check-pr-title.ts", ...args],
    stdout: "piped",
    stderr: "piped",
  });

  const { code, stdout, stderr } = await cmd.output();

  return {
    code,
    stdout: new TextDecoder().decode(stdout),
    stderr: new TextDecoder().decode(stderr),
  };
}

Deno.test(
  "Valid Angular-flavored Conventional Commits titles",
  async (t) => {
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
    ];

    for (const title of validTitles) {
      await t.step(`"${title}" should be valid`, () => {
        const result = checkTitle(title);

        assertEquals(result.valid, true, `Expected "${title}" to be valid`);
      });
    }
  },
);

Deno.test("Invalid PR titles", async (t) => {
  const invalidTitles = [
    { title: "", expectedError: "Error: PR title is empty" },
    {
      title: "invalid: bad type",
      expectedError:
        "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    },
    {
      title: "Add new feature",
      expectedError:
        "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    },
    {
      title: "feat:",
      expectedError:
        "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    },
    {
      title: "feat: ",
      expectedError:
        "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    },
    {
      title: "feat:  ",
      expectedError:
        "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    },
    {
      title: "unknown: some change",
      expectedError:
        "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    },
    {
      title: "feat add new feature",
      expectedError:
        "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    },
    {
      title: "feat()",
      expectedError:
        "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    },
    {
      title: "FEAT: uppercase type",
      expectedError:
        "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    },
  ];

  for (const { title, expectedError } of invalidTitles) {
    await t.step(`"${title}" should be invalid`, () => {
      const result = checkTitle(title);

      assertEquals(result.valid, false, `Expected "${title}" to be invalid`);
      if (!result.valid) {
        assertEquals(
          result.error,
          expectedError,
          `Expected specific error for "${title}"`,
        );
      }
    });
  }
});

Deno.test("Angular types are supported", async (t) => {
  const angularTypes = [
    "build",
    "chore",
    "ci",
    "docs",
    "feat",
    "fix",
    "perf",
    "refactor",
    "style",
    "test",
  ];

  for (const type of angularTypes) {
    await t.step(`Type "${type}" should be supported`, () => {
      const result = checkTitle(`${type}: test change`);

      assertEquals(result.valid, true, `Type "${type}" should be valid`);
    });
  }
});

Deno.test("Scope variations", async (t) => {
  await t.step("No scope should be valid", () => {
    const result = checkTitle("feat: add feature");

    assertEquals(result.valid, true);
  });

  await t.step("Single word scope should be valid", () => {
    const result = checkTitle("feat(auth): add feature");

    assertEquals(result.valid, true);
  });

  await t.step("Multi-word scope should be valid", () => {
    const result = checkTitle("feat(user-auth): add feature");

    assertEquals(result.valid, true);
  });

  await t.step("Empty scope should be invalid", () => {
    const result = checkTitle("feat(): add feature");

    assertEquals(result.valid, false);
    if (!result.valid) {
      assertEquals(
        result.error,
        "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
      );
    }
  });
});

Deno.test("CLI Integration Tests", async (t) => {
  await t.step("Valid title should exit with code 0", async () => {
    const { code, stdout, stderr } = await runCLI(["feat: add new feature"]);

    assertEquals(code, 0);
    assertEquals(
      stdout.includes(
        "PR title conforms to Angular-flavored Conventional Commits-like format",
      ),
      true,
    );
    assertEquals(stderr.trim(), "");
  });

  await t.step("Invalid title should exit with code 1", async () => {
    const { code, stdout, stderr } = await runCLI(["invalid title"]);

    assertEquals(code, 1);
    assertEquals(stderr.includes("Error:"), true);
    assertEquals(stdout.trim(), "");
  });

  await t.step("No arguments should exit with code 1", async () => {
    const { code, stdout, stderr } = await runCLI([]);

    assertEquals(code, 1);
    assertEquals(stderr.includes("Error: PR title is not specified"), true);
    assertEquals(stdout.trim(), "");
  });

  await t.step("--help should exit with code 0", async () => {
    const { code, stdout, stderr } = await runCLI(["--help"]);

    assertEquals(code, 0);
    assertEquals(stdout.includes("Usage:"), true);
    assertEquals(stdout.includes("Options:"), true);
    assertEquals(stderr.trim(), "");
  });

  await t.step("--version should exit with code 0", async () => {
    const { code, stdout, stderr } = await runCLI(["--version"]);

    assertEquals(code, 0);
    assertEquals(stdout.includes("check-pr-title 1.0.0"), true);
    assertEquals(stderr.trim(), "");
  });
});
