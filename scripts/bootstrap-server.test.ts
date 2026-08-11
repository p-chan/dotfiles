import { assertEquals, assertStringIncludes } from "@std/assert";
import { dirname, fromFileUrl, join } from "@std/path";

const taskPath = join(dirname(fromFileUrl(import.meta.url)), "../home/.config/mise/tasks/bootstrap-server");

interface Fixture {
  root: string;
  statePath: string;
  sudoLogPath: string;
}

async function createFixture(sleep: number, autorestart: number): Promise<Fixture> {
  const root = await Deno.makeTempDir();
  const binDir = join(root, "bin");
  const statePath = join(root, "pmset-state");
  const sudoLogPath = join(root, "sudo-log");
  await Deno.mkdir(binDir);
  await Deno.writeTextFile(statePath, powerSettings(sleep, autorestart));
  await Deno.writeTextFile(sudoLogPath, "");

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
  await Deno.writeTextFile(path, content);
  await Deno.chmod(path, 0o755);
}

async function runTask(fixture: Fixture, apply: boolean): Promise<Deno.CommandOutput> {
  return await new Deno.Command("bash", {
    args: [taskPath],
    clearEnv: true,
    env: {
      HOME: fixture.root,
      PATH: `${join(fixture.root, "bin")}:/usr/bin:/bin`,
      PMSET_STATE: fixture.statePath,
      SUDO_APPLY: String(apply),
      SUDO_LOG: fixture.sudoLogPath,
    },
    stdout: "piped",
    stderr: "piped",
  }).output();
}

Deno.test("bootstrap-server", async (t) => {
  await t.step("does not invoke sudo when settings already match", async () => {
    const fixture = await createFixture(0, 1);
    try {
      assertEquals((await runTask(fixture, false)).code, 0);
      assertEquals(await Deno.readTextFile(fixture.sudoLogPath), "");
    } finally {
      await Deno.remove(fixture.root, { recursive: true });
    }
  });

  await t.step("applies both settings when they drift", async () => {
    const fixture = await createFixture(1, 0);
    try {
      assertEquals((await runTask(fixture, true)).code, 0);
      assertEquals(await Deno.readTextFile(fixture.sudoLogPath), "pmset -c sleep 0 autorestart 1\n");
      assertEquals(await Deno.readTextFile(fixture.statePath), powerSettings(0, 1));
    } finally {
      await Deno.remove(fixture.root, { recursive: true });
    }
  });

  await t.step("fails when pmset does not converge", async () => {
    const fixture = await createFixture(1, 0);
    try {
      const result = await runTask(fixture, false);
      assertEquals(result.code, 1);
      assertStringIncludes(new TextDecoder().decode(result.stderr), "Failed to apply the server power settings.");
    } finally {
      await Deno.remove(fixture.root, { recursive: true });
    }
  });
});
