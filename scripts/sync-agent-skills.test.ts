import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdir, mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const scriptPath = join(dirname(fileURLToPath(import.meta.url)), "sync-agent-skills.sh");

function run(command: string, arguments_: string[], cwd?: string): string {
  const result = spawnSync(command, arguments_, { cwd, encoding: "utf8" });
  if (result.error) throw result.error;
  assert.equal(result.status, 0, result.stderr);
  return result.stdout;
}

test("sync-agent-skills installs pinned skills and prunes removed locators", async () => {
  const root = await mkdtemp(join(tmpdir(), "sync-agent-skills-"));
  const source = join(root, "source");
  const skillsDir = join(root, "home/.agents/skills");
  const manifest = join(root, "home/.agents/external-skills");

  try {
    await mkdir(join(source, "skills/example"), { recursive: true });
    await mkdir(skillsDir, { recursive: true });
    await writeFile(join(source, "skills/example/SKILL.md"), "---\nname: example\n---\n");
    run("git", ["init", "--quiet"], source);
    run("git", ["add", "."], source);
    run(
      "git",
      ["-c", "user.name=test", "-c", "user.email=test@example.com", "commit", "--quiet", "-m", "initial"],
      source,
    );
    const revision = run("git", ["rev-parse", "HEAD"], source).trim();

    await writeFile(manifest, `file://${source}#${revision}:skills/example\n`);
    assert.match(run("bash", [scriptPath, root]), /Installed example/);
    assert.equal(await readFile(join(skillsDir, "example/SKILL.md"), "utf8"), "---\nname: example\n---\n");

    await writeFile(manifest, "");
    run("bash", [scriptPath, root]);
    await assert.rejects(readFile(join(skillsDir, "example/SKILL.md"), "utf8"));
  } finally {
    await rm(root, { recursive: true });
  }
});
