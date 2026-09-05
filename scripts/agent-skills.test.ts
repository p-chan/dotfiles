import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { mkdir, mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const cliPath = join(dirname(fileURLToPath(import.meta.url)), "../bin/agent-skills");

function run(root: string, ...arguments_: string[]): string {
  const result = spawnSync("node", [cliPath, ...arguments_], {
    encoding: "utf8",
    env: { ...process.env, DOTFILES_DIR: root },
  });
  if (result.error) throw result.error;
  assert.equal(result.status, 0, result.stderr);
  return result.stdout;
}

function git(cwd: string, ...arguments_: string[]): string {
  const result = spawnSync("git", arguments_, { cwd, encoding: "utf8" });
  if (result.error) throw result.error;
  assert.equal(result.status, 0, result.stderr);
  return result.stdout;
}

test("agent-skills manages a pinned skill lifecycle", async () => {
  const root = await mkdtemp(join(tmpdir(), "agent-skills-"));
  const source = join(root, "source");
  const skillPath = join(source, "skills/example");
  const manifestPath = join(root, "home/.agents/skills.json");
  const installedSkillPath = join(root, "home/.agents/skills/example/SKILL.md");

  try {
    await mkdir(skillPath, { recursive: true });
    await mkdir(dirname(manifestPath), { recursive: true });
    await writeFile(manifestPath, '{"version":1,"skills":{}}\n');
    await writeFile(join(skillPath, "SKILL.md"), "first\n");
    git(source, "init", "--quiet");
    git(source, "add", ".");
    git(source, "-c", "user.name=test", "-c", "user.email=test@example.com", "commit", "--quiet", "-m", "first");
    const firstCommit = git(source, "rev-parse", "HEAD").trim();

    assert.match(run(root, "add", `file://${source}`, "skills/example"), /Installed example/);
    const installedSkill = JSON.parse(await readFile(manifestPath, "utf8")).skills.example;
    assert.equal(installedSkill.commit, firstCommit);
    assert.equal("ref" in installedSkill, false);
    assert.equal(await readFile(installedSkillPath, "utf8"), "first\n");

    await writeFile(join(skillPath, "SKILL.md"), "second\n");
    git(source, "add", ".");
    git(source, "-c", "user.name=test", "-c", "user.email=test@example.com", "commit", "--quiet", "-m", "second");
    const secondCommit = git(source, "rev-parse", "HEAD").trim();

    assert.match(run(root, "update", "example"), new RegExp(`${firstCommit} -> ${secondCommit}`));
    assert.equal(JSON.parse(await readFile(manifestPath, "utf8")).skills.example.commit, secondCommit);
    assert.equal(await readFile(installedSkillPath, "utf8"), "second\n");

    await writeFile(installedSkillPath, "drifted\n");
    run(root, "install", "example");
    assert.equal(await readFile(installedSkillPath, "utf8"), "second\n");

    run(root, "remove", "example");
    assert.deepEqual(JSON.parse(await readFile(manifestPath, "utf8")).skills, {});
    await assert.rejects(readFile(installedSkillPath, "utf8"));
  } finally {
    await rm(root, { recursive: true });
  }
});
