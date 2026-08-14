import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { chmod, mkdir, mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const taskPath = join(dirname(fileURLToPath(import.meta.url)), "../home/.config/mise/tasks/bootstrap-server");

interface Fixture {
  root: string;
  statePath: string;
  sudoLogPath: string;
}

async function createFixture(sleep: number, autorestart: number): Promise<Fixture> {
  const root = await mkdtemp(join(tmpdir(), "bootstrap-server-"));
  const binDir = join(root, "bin");
  const statePath = join(root, "pmset-state");
  const sudoLogPath = join(root, "sudo-log");
  await mkdir(binDir);
  await writeFile(statePath, powerSettings(sleep, autorestart));
  await writeFile(sudoLogPath, "");

  await writeExecutable(
    join(binDir, "uname"),
    `#!/bin/bash
printf 'Darwin\\n'
`,
  );
  await writeExecutable(
    join(binDir, "pmset"),
    `#!/bin/bash
while IFS= read -r line; do
  printf '%s\\n' "$line"
done < "$PMSET_STATE"
`,
  );
  await writeExecutable(
    join(binDir, "sudo"),
    `#!/bin/bash
printf '%s\\n' "$*" >> "$SUDO_LOG"
if [ "\${SUDO_APPLY:-false}" = "true" ]; then
  printf 'AC Power:\\n  sleep 0\\n  autorestart 1\\n' > "$PMSET_STATE"
fi
`,
  );

  return { root, statePath, sudoLogPath };
}

function powerSettings(sleep: number, autorestart: number): string {
  return `AC Power:
  sleep ${sleep}
  autorestart ${autorestart}
`;
}

async function writeExecutable(path: string, content: string): Promise<void> {
  await writeFile(path, content);
  await chmod(path, 0o755);
}

function runTask(fixture: Fixture, apply: boolean): { code: number; stderr: string } {
  const result = spawnSync("bash", [taskPath], {
    env: {
      HOME: fixture.root,
      PATH: `${join(fixture.root, "bin")}:/usr/bin:/bin`,
      PMSET_STATE: fixture.statePath,
      SUDO_APPLY: String(apply),
      SUDO_LOG: fixture.sudoLogPath,
    },
    encoding: "utf8",
  });
  if (result.error) throw result.error;
  return { code: result.status ?? 1, stderr: result.stderr };
}

test("bootstrap-server", async (t) => {
  await t.test("does not invoke sudo when settings already match", async () => {
    const fixture = await createFixture(0, 1);
    try {
      assert.equal(runTask(fixture, false).code, 0);
      assert.equal(await readFile(fixture.sudoLogPath, "utf8"), "");
    } finally {
      await rm(fixture.root, { recursive: true });
    }
  });

  await t.test("applies both settings when they drift", async () => {
    const fixture = await createFixture(1, 0);
    try {
      assert.equal(runTask(fixture, true).code, 0);
      assert.equal(await readFile(fixture.sudoLogPath, "utf8"), "pmset -c sleep 0 autorestart 1\n");
      assert.equal(await readFile(fixture.statePath, "utf8"), powerSettings(0, 1));
    } finally {
      await rm(fixture.root, { recursive: true });
    }
  });

  await t.test("fails when pmset does not converge", async () => {
    const fixture = await createFixture(1, 0);
    try {
      const result = runTask(fixture, false);
      assert.equal(result.code, 1);
      assert.match(result.stderr, /Failed to apply the server power settings\./);
    } finally {
      await rm(fixture.root, { recursive: true });
    }
  });
});
