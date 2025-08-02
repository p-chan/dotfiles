import { assertEquals, assertRejects } from "jsr:@std/assert@1.0.13";
import {
  Dependencies,
  exportExtensions,
  FileOperations,
  importExtensions,
  main,
  parseExtensionsList,
  RuntimeEnvironment,
  showHelp,
} from "./code-extensions.ts";

function createMockFileOperations(
  overrides: Partial<FileOperations> = {},
): FileOperations {
  const mockFileOperations: FileOperations = {
    readTextFile: () => Promise.resolve(""),
    writeTextFile: () => Promise.resolve(),
    ...overrides,
  };
  return mockFileOperations;
}

function createMockRuntimeEnvironment(
  overrides: Partial<RuntimeEnvironment> = {},
): RuntimeEnvironment {
  const mockRuntimeEnvironment: RuntimeEnvironment = {
    runCommand: () => Promise.resolve({ stdout: "" }),
    writeStdout: () => Promise.resolve(0),
    getEnv: () => undefined,
    exit: () => {
      throw new Error("Exit called");
    },
    log: () => {},
    error: () => {},
    ...overrides,
  };
  return mockRuntimeEnvironment;
}

function createMockDependencies(
  overrides: Partial<Dependencies> = {},
): Dependencies {
  const mockDependencies: Dependencies = {
    fileOperations: createMockFileOperations(),
    runtimeEnvironment: createMockRuntimeEnvironment(),
    ...overrides,
  };
  return mockDependencies;
}

async function runCLI(
  args: string[],
): Promise<{ code: number; stdout: string; stderr: string }> {
  const cmd = new Deno.Command("deno", {
    args: ["run", "-A", "scripts/code-extensions.ts", ...args],
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

Deno.test("parseExtensionsList", async (t) => {
  await t.step("should parse extension list correctly", () => {
    const content = `ms-python.python
ms-vscode.vscode-typescript-next
esbenp.prettier-vscode

# This is a comment
ms-vscode.vscode-json`;

    const result = parseExtensionsList(content);

    assertEquals(result, [
      "ms-python.python",
      "ms-vscode.vscode-typescript-next",
      "esbenp.prettier-vscode",
      "ms-vscode.vscode-json",
    ]);
  });

  await t.step("should handle empty content", () => {
    const result = parseExtensionsList("");
    assertEquals(result, []);
  });

  await t.step("should filter out comments and empty lines", () => {
    const content = `# Comment line
ext1

ext2
# Another comment
ext3
`;

    const result = parseExtensionsList(content);
    assertEquals(result, ["ext1", "ext2", "ext3"]);
  });

  await t.step("should trim whitespace", () => {
    const content = `  ext1
  ext2  `;

    const result = parseExtensionsList(content);
    assertEquals(result, ["ext1", "ext2"]);
  });

  await t.step("should handle whitespace-only lines", () => {
    const content = `ext1

\t\t
ext2
    `;

    const result = parseExtensionsList(content);
    assertEquals(result, ["ext1", "ext2"]);
  });
});

Deno.test("importExtensions", async (t) => {
  await t.step("should import extensions successfully", async () => {
    const logs: string[] = [];
    const stdout: Uint8Array[] = [];
    const commands: string[][] = [];

    const mockDependencies = createMockDependencies({
      fileOperations: createMockFileOperations({
        readTextFile: () => Promise.resolve("ext1\next2"),
      }),
      runtimeEnvironment: createMockRuntimeEnvironment({
        log: (msg) => logs.push(msg),
        writeStdout: (data) => {
          stdout.push(data);
          return Promise.resolve(data.length);
        },
        runCommand: (args) => {
          commands.push(args);
          return Promise.resolve({ stdout: "" });
        },
      }),
    });

    await importExtensions("/test/path", mockDependencies);

    assertEquals(logs[0], "2 extensions found to install.\n");
    assertEquals(logs[1], "\nAll extensions have been installed.");
    assertEquals(commands.length, 2);
    assertEquals(commands[0], ["code", "--install-extension", "ext1"]);
    assertEquals(commands[1], ["code", "--install-extension", "ext2"]);
  });

  await t.step("should handle file read error", async () => {
    const mockDependencies = createMockDependencies({
      fileOperations: createMockFileOperations({
        readTextFile: () => Promise.reject(new Error("File not found")),
      }),
    });

    await assertRejects(
      () => importExtensions("/test/path", mockDependencies),
      Error,
      "File not found",
    );
  });

  await t.step("should handle empty extension list", async () => {
    const logs: string[] = [];

    const mockDependencies = createMockDependencies({
      fileOperations: createMockFileOperations({
        readTextFile: () => Promise.resolve(""),
      }),
      runtimeEnvironment: createMockRuntimeEnvironment({
        log: (msg) => logs.push(msg),
      }),
    });

    await importExtensions("/test/path", mockDependencies);

    assertEquals(logs[0], "0 extensions found to install.\n");
    assertEquals(logs[1], "\nAll extensions have been installed.");
  });

  await t.step("should handle writeStdout error", async () => {
    const mockDependencies = createMockDependencies({
      fileOperations: createMockFileOperations({
        readTextFile: () => Promise.resolve("ext1"),
      }),
      runtimeEnvironment: createMockRuntimeEnvironment({
        log: () => {},
        writeStdout: () => Promise.reject(new Error("Write failed")),
        runCommand: () => Promise.resolve({ stdout: "" }),
      }),
    });

    await assertRejects(
      () => importExtensions("/test/path", mockDependencies),
      Error,
      "Write failed",
    );
  });
});

Deno.test("exportExtensions", async (t) => {
  await t.step("should export extensions successfully", async () => {
    const logs: string[] = [];
    const writeOperations: Array<{ path: string; content: string }> = [];

    const mockDependencies = createMockDependencies({
      fileOperations: createMockFileOperations({
        writeTextFile: (path, content) => {
          writeOperations.push({ path, content });
          return Promise.resolve();
        },
      }),
      runtimeEnvironment: createMockRuntimeEnvironment({
        runCommand: () => Promise.resolve({ stdout: "ext1\next2\n" }),
        log: (msg) => logs.push(msg),
      }),
    });

    await exportExtensions("/test/path", mockDependencies);

    assertEquals(writeOperations.length, 1);
    assertEquals(writeOperations[0].path, "/test/path");
    assertEquals(writeOperations[0].content, "ext1\next2\n");
    assertEquals(
      logs[0],
      "Extensions have been exported to /test/path",
    );
  });

  await t.step("should handle command execution error", async () => {
    const mockDependencies = createMockDependencies({
      runtimeEnvironment: createMockRuntimeEnvironment({
        runCommand: () => Promise.reject(new Error("Command failed")),
      }),
    });

    await assertRejects(
      () => exportExtensions("/test/path", mockDependencies),
      Error,
      "Command failed",
    );
  });

  await t.step("should handle file write error", async () => {
    const mockDependencies = createMockDependencies({
      fileOperations: createMockFileOperations({
        writeTextFile: () =>
          Promise.reject(new Error("Write permission denied")),
      }),
      runtimeEnvironment: createMockRuntimeEnvironment({
        runCommand: () => Promise.resolve({ stdout: "ext1\next2" }),
        log: () => {},
      }),
    });

    await assertRejects(
      () => exportExtensions("/test/path", mockDependencies),
      Error,
      "Write permission denied",
    );
  });
});

Deno.test("showHelp", async (t) => {
  await t.step("should display help message", () => {
    const logs: string[] = [];

    const mockDependencies = createMockDependencies({
      runtimeEnvironment: createMockRuntimeEnvironment({
        log: (msg) => logs.push(msg),
      }),
    });

    showHelp(mockDependencies);

    assertEquals(logs.length, 1);
    assertEquals(logs[0].includes("code-extensions v1.0.0"), true);
    assertEquals(logs[0].includes("Usage:"), true);
    assertEquals(logs[0].includes("Commands:"), true);
  });
});

Deno.test("main function", async (t) => {
  await t.step("should handle import command", async () => {
    const logs: string[] = [];
    let exitCalled = false;

    const mockDependencies = createMockDependencies({
      fileOperations: createMockFileOperations({
        readTextFile: () => Promise.resolve("ext1"),
      }),
      runtimeEnvironment: createMockRuntimeEnvironment({
        getEnv: (name) => name === "DOTFILES_DIR" ? "/test" : undefined,
        log: (msg) => logs.push(msg),
        writeStdout: () => Promise.resolve(0),
        runCommand: () => Promise.resolve({ stdout: "" }),
        exit: () => {
          exitCalled = true;
          throw new Error("Exit called");
        },
      }),
    });

    await main(["import"], mockDependencies);

    assertEquals(exitCalled, false);
    assertEquals(logs.some((log) => log.includes("extensions found")), true);
  });

  await t.step("should handle export command", async () => {
    const logs: string[] = [];

    const mockDependencies = createMockDependencies({
      fileOperations: createMockFileOperations({
        writeTextFile: () => Promise.resolve(),
      }),
      runtimeEnvironment: createMockRuntimeEnvironment({
        getEnv: (name) => name === "DOTFILES_DIR" ? "/test" : undefined,
        runCommand: () => Promise.resolve({ stdout: "ext1\n" }),
        log: (msg) => logs.push(msg),
      }),
    });

    await main(["export"], mockDependencies);

    assertEquals(
      logs.some((log) => log.includes("Extensions have been exported")),
      true,
    );
  });

  await t.step("should handle help command", async () => {
    const logs: string[] = [];

    const mockDependencies = createMockDependencies({
      runtimeEnvironment: createMockRuntimeEnvironment({
        getEnv: (name) => name === "DOTFILES_DIR" ? "/test" : undefined,
        log: (msg) => logs.push(msg),
      }),
    });

    await main(["help"], mockDependencies);

    assertEquals(
      logs.some((log) => log.includes("code-extensions v1.0.0")),
      true,
    );
  });

  await t.step("should handle unknown command", async () => {
    const logs: string[] = [];
    let exitCalled = false;

    const mockDependencies = createMockDependencies({
      runtimeEnvironment: createMockRuntimeEnvironment({
        getEnv: (name) => name === "DOTFILES_DIR" ? "/test" : undefined,
        log: (msg) => logs.push(msg),
        exit: () => {
          exitCalled = true;
          throw new Error("Exit called");
        },
      }),
    });

    try {
      await main(["unknown"], mockDependencies);
    } catch (error) {
      assertEquals((error as Error).message, "Exit called");
    }

    assertEquals(exitCalled, true);
    assertEquals(logs.some((log) => log.includes("Unknown command")), true);
  });

  await t.step("should handle missing DOTFILES_DIR", async () => {
    const errors: string[] = [];
    let exitCalled = false;

    const mockDependencies = createMockDependencies({
      runtimeEnvironment: createMockRuntimeEnvironment({
        getEnv: () => undefined,
        error: (msg) => errors.push(msg),
        exit: () => {
          exitCalled = true;
          throw new Error("Exit called");
        },
      }),
    });

    try {
      await main(["import"], mockDependencies);
    } catch (error) {
      assertEquals((error as Error).message, "Exit called");
    }

    assertEquals(exitCalled, true);
    assertEquals(
      errors[0],
      "DOTFILES_DIR environment variable is not set.",
    );
  });

  await t.step("should handle no arguments (default to help)", async () => {
    const logs: string[] = [];

    const mockDependencies = createMockDependencies({
      runtimeEnvironment: createMockRuntimeEnvironment({
        getEnv: (name) => name === "DOTFILES_DIR" ? "/test" : undefined,
        log: (msg) => logs.push(msg),
      }),
    });

    await main([], mockDependencies);

    assertEquals(
      logs.some((log) => log.includes("code-extensions v1.0.0")),
      true,
    );
  });
});

Deno.test("CLI Integration Tests", async (t) => {
  await t.step("help command should exit with code 0", async () => {
    const { code, stdout } = await runCLI(["help"]);

    assertEquals(code, 0);
    assertEquals(stdout.includes("code-extensions v1.0.0"), true);
    assertEquals(stdout.includes("Usage:"), true);
  });

  await t.step("unknown command should exit with code 1", async () => {
    const { code, stdout } = await runCLI(["unknown"]);

    assertEquals(code, 1);
    assertEquals(stdout.includes("Unknown command"), true);
  });

  await t.step("no DOTFILES_DIR should exit with code 1", async () => {
    const cmd = new Deno.Command("deno", {
      args: ["run", "-A", "scripts/code-extensions.ts", "import"],
      stdout: "piped",
      stderr: "piped",
      env: { PATH: Deno.env.get("PATH") || "" },
      clearEnv: true,
    });

    const { code, stdout, stderr } = await cmd.output();
    const stdoutText = new TextDecoder().decode(stdout);
    const stderrText = new TextDecoder().decode(stderr);

    assertEquals(code, 1);
    assertEquals(
      stdoutText.includes("DOTFILES_DIR environment variable is not set") ||
        stderrText.includes("DOTFILES_DIR environment variable is not set"),
      true,
    );
  });
});
