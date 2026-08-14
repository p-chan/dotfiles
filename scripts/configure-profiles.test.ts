import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { lstat, mkdir, mkdtemp, readlink, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const scriptPath = join(dirname(fileURLToPath(import.meta.url)), "configure-profiles.sh");

async function createDotfilesFixture(): Promise<string> {
  const root = await mkdtemp(join(tmpdir(), "configure-profiles-"));
  const profilesDir = join(root, "home/.config/mise/profiles");
  await mkdir(profilesDir, { recursive: true });
  await Promise.all([
    writeFile(join(profilesDir, "desktop.toml"), "[bootstrap]\n"),
    writeFile(join(profilesDir, "server.toml"), "[bootstrap]\n"),
  ]);
  return root;
}

function configure(root: string, profiles?: string): { code: number; stdout: string } {
  const env: Record<string, string> = {
    HOME: process.env.HOME ?? "/tmp",
    PATH: process.env.PATH ?? "/usr/bin:/bin",
  };
  if (profiles !== undefined) env.DOTFILES_PROFILES = profiles;

  const result = spawnSync("bash", [scriptPath, root], {
    env,
    encoding: "utf8",
  });
  if (result.error) throw result.error;
  return { code: result.status ?? 1, stdout: result.stdout };
}

function activationPath(root: string, profile: string): string {
  return join(root, `home/.config/mise/conf.d/profile-${profile}.toml`);
}

test("configure-profiles", async (t) => {
  await t.test("defaults to desktop on first run", async () => {
    const root = await createDotfilesFixture();
    try {
      const result = configure(root);
      assert.equal(result.code, 0);
      assert.equal(await readlink(activationPath(root, "desktop")), "../profiles/desktop.toml");
      assert.equal(await exists(activationPath(root, "server")), false);
    } finally {
      await rm(root, { recursive: true });
    }
  });

  await t.test("normalizes and composes explicit profiles", async () => {
    const root = await createDotfilesFixture();
    try {
      const result = configure(root, "server, desktop,server");
      assert.equal(result.code, 0);
      assert.equal(result.stdout, "Active dotfiles profiles: desktop,server\n");
      assert.equal(await readlink(activationPath(root, "desktop")), "../profiles/desktop.toml");
      assert.equal(await readlink(activationPath(root, "server")), "../profiles/server.toml");
    } finally {
      await rm(root, { recursive: true });
    }
  });

  await t.test("preserves the saved selection when no override is provided", async () => {
    const root = await createDotfilesFixture();
    try {
      assert.equal(configure(root, "server").code, 0);
      assert.equal(configure(root).code, 0);
      assert.equal(await exists(activationPath(root, "desktop")), false);
      assert.equal(await readlink(activationPath(root, "server")), "../profiles/server.toml");
    } finally {
      await rm(root, { recursive: true });
    }
  });

  await t.test("replaces the saved selection with an explicit profile", async () => {
    const root = await createDotfilesFixture();
    try {
      assert.equal(configure(root, "server").code, 0);
      assert.equal(configure(root, "desktop").code, 0);
      assert.equal(await readlink(activationPath(root, "desktop")), "../profiles/desktop.toml");
      assert.equal(await exists(activationPath(root, "server")), false);
    } finally {
      await rm(root, { recursive: true });
    }
  });

  await t.test("rejects unknown profiles without changing the saved selection", async () => {
    const root = await createDotfilesFixture();
    try {
      assert.equal(configure(root, "desktop").code, 0);
      const result = configure(root, "desktop,unknown");
      assert.equal(result.code, 1);
      assert.equal(await readlink(activationPath(root, "desktop")), "../profiles/desktop.toml");
      assert.equal(await exists(activationPath(root, "server")), false);
    } finally {
      await rm(root, { recursive: true });
    }
  });
});

async function exists(path: string): Promise<boolean> {
  try {
    await lstat(path);
    return true;
  } catch (error) {
    if (error && typeof error === "object" && "code" in error && error.code === "ENOENT") return false;
    throw error;
  }
}
