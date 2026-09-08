import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { chmod, lstat, mkdir, mkdtemp, readFile, rm, symlink, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const repositoryRoot = join(dirname(fileURLToPath(import.meta.url)), "..");
const filterPath = join(repositoryRoot, "home/.config/git/filters/claude-settings.sh");
const gitConfigPath = join(repositoryRoot, "home/.config/git/config");
const installerPath = join(repositoryRoot, "scripts/install-herdr-claude-integration.sh");
const attributesPath = join(repositoryRoot, ".gitattributes");
const settingsPath = join(repositoryRoot, "home/.claude/settings.json");
const settingsRelativePath = "home/.claude/settings.json";
const portableCommand = 'bash "$HOME/.claude/hooks/herdr-agent-state.sh" session';

interface Fixture {
  root: string;
  repository: string;
  home: string;
  herdrLog: string;
  environment: NodeJS.ProcessEnv;
}

function commandPath(command: string): string {
  const miseResult = spawnSync("mise", ["which", command], { encoding: "utf8" });
  if (miseResult.status === 0) return miseResult.stdout.trim();

  const result = spawnSync("/bin/sh", ["-c", `command -v ${command}`], { encoding: "utf8" });
  if (result.error) throw result.error;
  assert.equal(result.status, 0, result.stderr);
  return result.stdout.trim();
}

async function writeExecutable(path: string, content: string): Promise<void> {
  await writeFile(path, content);
  await chmod(path, 0o755);
}

function git(fixture: Fixture, ...arguments_: string[]): ReturnType<typeof spawnSync> {
  const result = spawnSync("git", ["-C", fixture.repository, ...arguments_], {
    encoding: "utf8",
    env: fixture.environment,
  });
  if (result.error) throw result.error;
  return result;
}

function runInstaller(fixture: Fixture): ReturnType<typeof spawnSync> {
  const result = spawnSync("/bin/bash", [installerPath], {
    encoding: "utf8",
    env: fixture.environment,
  });
  if (result.error) throw result.error;
  return result;
}

function localCommand(home: string): string {
  const path = `${home}/.claude/hooks/herdr-agent-state.sh`.replaceAll("'", `'"'"'`);
  return `bash '${path}' session`;
}

async function createFixture(): Promise<Fixture> {
  const root = await mkdtemp(join(tmpdir(), "bootstrap-herdr-"));
  const repository = join(root, "dotfiles");
  const home = join(root, "user-home");
  const bin = join(root, "bin");
  const herdrLog = join(root, "herdr.log");
  const repositorySettingsPath = join(repository, settingsRelativePath);
  const trustedGitDirectory = join(home, ".config/git");

  await Promise.all([
    mkdir(dirname(repositorySettingsPath), { recursive: true }),
    mkdir(join(trustedGitDirectory, "filters"), { recursive: true }),
    mkdir(bin, { recursive: true }),
  ]);
  await Promise.all([
    writeFile(join(repository, ".gitattributes"), await readFile(attributesPath)),
    writeFile(repositorySettingsPath, cleanSettings(await readFile(settingsPath))),
    writeFile(join(repository, "README.md"), "fixture\n"),
    writeFile(herdrLog, ""),
    symlink(gitConfigPath, join(trustedGitDirectory, "config")),
    symlink(filterPath, join(trustedGitDirectory, "filters/claude-settings.sh")),
    symlink(process.execPath, join(bin, "node")),
    symlink(commandPath("jq"), join(bin, "jq")),
  ]);
  await writeExecutable(
    join(bin, "herdr"),
    `#!/bin/bash
if [ "$1" != integration ] || [ "$2" != install ]; then
  exit 1
fi
if [ "$3" = claude ]; then
  actual_command="$(jq -r '.hooks.SessionStart[0].hooks[0].command' "$CLAUDE_SETTINGS_PATH")"
  if [ "$actual_command" != "$EXPECTED_CLAUDE_COMMAND" ]; then
    printf 'unexpected Claude hook command: %s\n' "$actual_command" >&2
    exit 1
  fi
fi
printf '%s\n' "$3" >> "$HERDR_LOG"
`,
  );

  const setupEnvironment = {
    ...process.env,
    GIT_CONFIG_GLOBAL: "/dev/null",
    GIT_CONFIG_NOSYSTEM: "1",
    HOME: home,
  };
  assert.equal(spawnSync("git", ["init", "--quiet", repository], { env: setupEnvironment }).status, 0);
  assert.equal(spawnSync("git", ["-C", repository, "add", "."], { env: setupEnvironment }).status, 0);
  assert.equal(
    spawnSync(
      "git",
      [
        "-C",
        repository,
        "-c",
        "user.name=test",
        "-c",
        "user.email=test@example.com",
        "commit",
        "--quiet",
        "-m",
        "fixture",
      ],
      { env: setupEnvironment },
    ).status,
    0,
  );

  const environment = {
    CI: "true",
    CLAUDE_SETTINGS_PATH: repositorySettingsPath,
    EXPECTED_CLAUDE_COMMAND: localCommand(home),
    GIT_CONFIG_NOSYSTEM: "1",
    HERDR_LOG: herdrLog,
    HOME: home,
    PATH: `${bin}:/usr/bin:/bin`,
    DOTFILES_DIR: repository,
    XDG_CONFIG_HOME: join(home, ".config"),
  };

  return { root, repository, home, herdrLog, environment };
}

function cleanSettings(input: Buffer): Buffer {
  const result = spawnSync("/bin/bash", [filterPath, "clean"], {
    env: process.env,
    input,
  });
  if (result.error) throw result.error;
  assert.equal(result.status, 0, result.stderr.toString());
  return result.stdout;
}

test("installer configures Herdr without dirtying Claude settings", async () => {
  const fixture = await createFixture();
  const repositorySettingsPath = join(fixture.repository, settingsRelativePath);

  try {
    const before = JSON.parse(await readFile(repositorySettingsPath, "utf8"));
    assert.equal(before.hooks.SessionStart[0].hooks[0].command, portableCommand);
    const modeBefore = (await lstat(repositorySettingsPath)).mode & 0o777;

    const attributes = git(fixture, "check-attr", "filter", "export-ignore", "--", settingsRelativePath);
    assert.equal(attributes.status, 0, attributes.stderr);
    assert.match(attributes.stdout, /filter: pchan-dotfiles-claude-settings/);
    assert.match(attributes.stdout, /export-ignore: set/);

    const firstRun = runInstaller(fixture);
    assert.equal(firstRun.status, 0, firstRun.stderr);
    assert.equal(await readFile(fixture.herdrLog, "utf8"), "claude\n");
    assert.equal((await lstat(repositorySettingsPath)).mode & 0o777, modeBefore);

    const worktreeSettings = JSON.parse(await readFile(repositorySettingsPath, "utf8"));
    assert.equal(worktreeSettings.hooks.SessionStart[0].hooks[0].command, localCommand(fixture.home));
    const indexedSettings = JSON.parse(git(fixture, "show", `:${settingsRelativePath}`).stdout);
    assert.equal(indexedSettings.hooks.SessionStart[0].hooks[0].command, portableCommand);
    assert.equal(git(fixture, "status", "--porcelain").stdout, "");

    const archive = spawnSync("git", ["-C", fixture.repository, "archive", "--format=tar", "HEAD"], {
      env: fixture.environment,
    });
    assert.equal(archive.status, 0, archive.stderr.toString());
    const archivedFiles = spawnSync("tar", ["-tf", "-"], {
      encoding: "utf8",
      env: fixture.environment,
      input: archive.stdout,
    });
    assert.equal(archivedFiles.status, 0, archivedFiles.stderr);
    assert.doesNotMatch(archivedFiles.stdout, /home\/\.claude\/settings\.json/);

    const worktreeContent = await readFile(repositorySettingsPath, "utf8");
    const secondRun = runInstaller(fixture);
    assert.equal(secondRun.status, 0, secondRun.stderr);
    assert.equal(await readFile(repositorySettingsPath, "utf8"), worktreeContent);
    assert.equal(git(fixture, "status", "--porcelain").stdout, "");

    const stagedDeletion = git(fixture, "rm", "--cached", "--", settingsRelativePath);
    assert.equal(stagedDeletion.status, 0, stagedDeletion.stderr);
    const deletionRun = runInstaller(fixture);
    assert.equal(deletionRun.status, 0, deletionRun.stderr);
    assert.equal(git(fixture, "ls-files", "--", settingsRelativePath).stdout, "");
    assert.equal(git(fixture, "reset", "HEAD", "--", settingsRelativePath).status, 0);

    worktreeSettings.localChange = true;
    await writeFile(repositorySettingsPath, `${JSON.stringify(worktreeSettings, null, 2)}\n`);
    const dirtyRun = runInstaller(fixture);
    assert.equal(dirtyRun.status, 0, dirtyRun.stderr);
    assert.equal(JSON.parse(await readFile(repositorySettingsPath, "utf8")).localChange, true);
    assert.equal(JSON.parse(git(fixture, "show", `:${settingsRelativePath}`).stdout).localChange, undefined);
    assert.equal(git(fixture, "diff", "--cached", "--name-only").stdout, "");
    assert.equal(git(fixture, "diff", "--quiet", "--", settingsRelativePath).status, 1);
  } finally {
    await rm(fixture.root, { recursive: true });
  }
});
