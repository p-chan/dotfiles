import { assertEquals } from "@std/assert";
import { dirname, fromFileUrl, join } from "@std/path";

const scriptPath = join(dirname(fromFileUrl(import.meta.url)), "configure-profiles.sh");

async function createDotfilesFixture(): Promise<string> {
  const root = await Deno.makeTempDir();
  const profilesDir = join(root, "home/.config/mise/profiles");
  await Deno.mkdir(profilesDir, { recursive: true });
  await Promise.all([
    Deno.writeTextFile(join(profilesDir, "desktop.toml"), "[bootstrap]\n"),
    Deno.writeTextFile(join(profilesDir, "server.toml"), "[bootstrap]\n"),
  ]);
  return root;
}

async function configure(root: string, profiles?: string): Promise<Deno.CommandOutput> {
  const env: Record<string, string> = {
    HOME: Deno.env.get("HOME") ?? "/tmp",
    PATH: Deno.env.get("PATH") ?? "/usr/bin:/bin",
  };
  if (profiles !== undefined) env.DOTFILES_PROFILES = profiles;

  return await new Deno.Command("bash", {
    args: [scriptPath, root],
    clearEnv: true,
    env,
    stdout: "piped",
    stderr: "piped",
  }).output();
}

function activationPath(root: string, profile: string): string {
  return join(root, `home/.config/mise/conf.d/profile-${profile}.toml`);
}

Deno.test("configure-profiles", async (t) => {
  await t.step("defaults to desktop on first run", async () => {
    const root = await createDotfilesFixture();
    try {
      const result = await configure(root);
      assertEquals(result.code, 0);
      assertEquals(await Deno.readLink(activationPath(root, "desktop")), "../profiles/desktop.toml");
      assertEquals(await exists(activationPath(root, "server")), false);
    } finally {
      await Deno.remove(root, { recursive: true });
    }
  });

  await t.step("normalizes and composes explicit profiles", async () => {
    const root = await createDotfilesFixture();
    try {
      const result = await configure(root, "server, desktop,server");
      assertEquals(result.code, 0);
      assertEquals(new TextDecoder().decode(result.stdout), "Active dotfiles profiles: desktop,server\n");
      assertEquals(await Deno.readLink(activationPath(root, "desktop")), "../profiles/desktop.toml");
      assertEquals(await Deno.readLink(activationPath(root, "server")), "../profiles/server.toml");
    } finally {
      await Deno.remove(root, { recursive: true });
    }
  });

  await t.step("preserves the saved selection when no override is provided", async () => {
    const root = await createDotfilesFixture();
    try {
      assertEquals((await configure(root, "server")).code, 0);
      assertEquals((await configure(root)).code, 0);
      assertEquals(await exists(activationPath(root, "desktop")), false);
      assertEquals(await Deno.readLink(activationPath(root, "server")), "../profiles/server.toml");
    } finally {
      await Deno.remove(root, { recursive: true });
    }
  });

  await t.step("replaces the saved selection with an explicit profile", async () => {
    const root = await createDotfilesFixture();
    try {
      assertEquals((await configure(root, "server")).code, 0);
      assertEquals((await configure(root, "desktop")).code, 0);
      assertEquals(await Deno.readLink(activationPath(root, "desktop")), "../profiles/desktop.toml");
      assertEquals(await exists(activationPath(root, "server")), false);
    } finally {
      await Deno.remove(root, { recursive: true });
    }
  });

  await t.step("rejects unknown profiles without changing the saved selection", async () => {
    const root = await createDotfilesFixture();
    try {
      assertEquals((await configure(root, "desktop")).code, 0);
      const result = await configure(root, "desktop,unknown");
      assertEquals(result.code, 1);
      assertEquals(await Deno.readLink(activationPath(root, "desktop")), "../profiles/desktop.toml");
      assertEquals(await exists(activationPath(root, "server")), false);
    } finally {
      await Deno.remove(root, { recursive: true });
    }
  });
});

async function exists(path: string): Promise<boolean> {
  try {
    await Deno.lstat(path);
    return true;
  } catch (error) {
    if (error instanceof Deno.errors.NotFound) return false;
    throw error;
  }
}
