import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { chmod, mkdir, mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const taskPath = join(dirname(fileURLToPath(import.meta.url)), "../home/.config/mise/tasks/bootstrap");

interface Fixture {
  root: string;
  dotfilesDir: string;
  enrollmentPath: string;
  namePath: string;
  sudoLogPath: string;
  herdrLogPath: string;
}

async function createFixture(enrolled: boolean, currentName: string): Promise<Fixture> {
  const root = await mkdtemp(join(tmpdir(), "bootstrap-"));
  const binDir = join(root, "bin");
  const dotfilesDir = join(root, "dotfiles");
  const enrollmentPath = join(root, "enrollment");
  const namePath = join(root, "name");
  const sudoLogPath = join(root, "sudo-log");
  const herdrLogPath = join(root, "herdr-log");

  await mkdir(binDir);
  await mkdir(join(dotfilesDir, "scripts"), { recursive: true });
  await mkdir(join(dotfilesDir, "home/.config/yazi"), { recursive: true });
  await mkdir(join(dotfilesDir, "home/.config/gh"), { recursive: true });
  await writeFile(join(dotfilesDir, "home/.config/yazi/packages.txt"), "");
  await writeFile(join(dotfilesDir, "home/.config/gh/extensions"), "");
  await writeFile(enrollmentPath, enrolled ? "Yes" : "No");
  await writeFile(namePath, currentName);
  await writeFile(sudoLogPath, "");
  await writeFile(herdrLogPath, "");

  // The steps after the rename must keep running; this records that they did.
  await writeExecutable(
    join(dotfilesDir, "scripts/install-herdr-claude-integration.sh"),
    `#!/bin/bash
printf 'installed\\n' >> "$HERDR_LOG"
`,
  );

  await writeExecutable(
    join(binDir, "mise"),
    `#!/bin/bash
printf '%s\\n' "$DOTFILES_ROOT_STUB"
`,
  );
  await writeExecutable(
    join(binDir, "profiles"),
    `#!/bin/bash
printf 'Enrolled via DEP: %s\\nMDM enrollment: %s\\n' "$(<"$ENROLLMENT_STATE")" "$(<"$ENROLLMENT_STATE")"
`,
  );
  await writeExecutable(
    join(binDir, "system_profiler"),
    `#!/bin/bash
printf '      Model Name: MacBook Air\\n'
`,
  );
  await writeExecutable(
    join(binDir, "scutil"),
    `#!/bin/bash
printf '%s\\n' "$(<"$NAME_STATE")"
`,
  );
  await writeExecutable(
    join(binDir, "sudo"),
    `#!/bin/bash
printf '%s\\n' "$*" >> "$SUDO_LOG"
`,
  );
  // Present so the task skips its installer; both are no-ops here.
  await writeExecutable(join(binDir, "claude"), "#!/bin/bash\n");
  await writeExecutable(join(binDir, "gh"), "#!/bin/bash\n");

  return { root, dotfilesDir, enrollmentPath, namePath, sudoLogPath, herdrLogPath };
}

async function writeExecutable(path: string, content: string): Promise<void> {
  await writeFile(path, content);
  await chmod(path, 0o755);
}

function runTask(fixture: Fixture): { code: number; stdout: string; stderr: string } {
  const result = spawnSync("bash", [taskPath], {
    env: {
      HOME: fixture.root,
      PATH: `${join(fixture.root, "bin")}:/usr/bin:/bin`,
      DOTFILES_ROOT_STUB: join(fixture.dotfilesDir, "home"),
      ENROLLMENT_STATE: fixture.enrollmentPath,
      NAME_STATE: fixture.namePath,
      SUDO_LOG: fixture.sudoLogPath,
      HERDR_LOG: fixture.herdrLogPath,
    },
    encoding: "utf8",
  });
  if (result.error) throw result.error;
  return { code: result.status ?? 1, stdout: result.stdout, stderr: result.stderr };
}

test("bootstrap", async (t) => {
  await t.test("skips the rename on an MDM-enrolled Mac and keeps going", async () => {
    const fixture = await createFixture(true, "managed-mac-0001");
    try {
      const result = runTask(fixture);
      assert.equal(result.code, 0);
      assert.match(result.stdout, /Skipping the machine rename/);
      assert.equal(await readFile(fixture.sudoLogPath, "utf8"), "");
      assert.equal(await readFile(fixture.herdrLogPath, "utf8"), "installed\n");
    } finally {
      await rm(fixture.root, { recursive: true });
    }
  });

  await t.test("renames an unmanaged Mac whose name drifted", async () => {
    const fixture = await createFixture(false, "managed-mac-0001");
    try {
      assert.equal(runTask(fixture).code, 0);
      assert.equal(
        await readFile(fixture.sudoLogPath, "utf8"),
        "scutil --set ComputerName P-Chan's MacBook Air\nscutil --set LocalHostName p-chan-macbook-air\n",
      );
    } finally {
      await rm(fixture.root, { recursive: true });
    }
  });

  await t.test("does not invoke sudo when the name already matches", async () => {
    const fixture = await createFixture(false, "P-Chan's MacBook Air");
    try {
      assert.equal(runTask(fixture).code, 0);
      assert.equal(await readFile(fixture.sudoLogPath, "utf8"), "scutil --set LocalHostName p-chan-macbook-air\n");
    } finally {
      await rm(fixture.root, { recursive: true });
    }
  });
});
