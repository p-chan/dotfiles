import * as path from "jsr:@std/path@1.1.1";
import { $ } from "jsr:@webpod/zx@8.7.1";
import { parseArgs } from "jsr:@std/cli@1.0.21";

export type FileOperations = {
  readTextFile: (path: string) => Promise<string>;
  writeTextFile: (path: string, content: string) => Promise<void>;
};

export type RuntimeEnvironment = {
  runCommand: (command: string[]) => Promise<{ stdout: string }>;
  writeStdout: (data: Uint8Array) => Promise<number>;
  getEnv: (name: string) => string | undefined;
  exit: (code: number) => never;
  log: (message: string) => void;
  error: (message: string) => void;
};

export type Dependencies = {
  fileOperations: FileOperations;
  runtimeEnvironment: RuntimeEnvironment;
};

const defaultFileOperations: FileOperations = {
  readTextFile: Deno.readTextFile,
  writeTextFile: Deno.writeTextFile,
};

const defaultRuntimeEnvironment: RuntimeEnvironment = {
  runCommand: async (args: string[]) => {
    const result = await $`${args}`;
    return { stdout: result.stdout };
  },
  writeStdout: (data: Uint8Array) => Deno.stdout.write(data),
  getEnv: Deno.env.get,
  exit: Deno.exit,
  log: console.log,
  error: console.error,
};

const defaultDependencies: Dependencies = {
  fileOperations: defaultFileOperations,
  runtimeEnvironment: defaultRuntimeEnvironment,
};

export function parseExtensionsList(content: string): string[] {
  return content
    .split("\n")
    .map((line) => line.trim())
    .filter((line) => line && !line.startsWith("#"));
}

export async function importExtensions(
  extensionsFilePath: string,
  dependencies: Dependencies = defaultDependencies,
): Promise<void> {
  const { fileOperations, runtimeEnvironment } = dependencies;
  const content = await fileOperations.readTextFile(extensionsFilePath);
  const extensions = parseExtensionsList(content);

  runtimeEnvironment.log(`${extensions.length} extensions found to install.\n`);

  const textEncoder = new TextEncoder();

  for (const extension of extensions) {
    await runtimeEnvironment.writeStdout(
      textEncoder.encode(`Installing ${extension}...`),
    );

    const codeCommand = Deno.env.get("CODE_COMMAND_PATH") ?? "code";

    await runtimeEnvironment.runCommand([
      codeCommand,
      "--install-extension",
      extension,
    ]);

    await runtimeEnvironment.writeStdout(
      textEncoder.encode(`\r\x1b[KInstalled ${extension}\n`),
    );
  }

  runtimeEnvironment.log("\nAll extensions have been installed.");
}

export async function exportExtensions(
  extensionsFilePath: string,
  dependencies: Dependencies = defaultDependencies,
): Promise<void> {
  const { fileOperations, runtimeEnvironment } = dependencies;

  const codeCommand = Deno.env.get("CODE_COMMAND_PATH") ?? "code";

  const { stdout: extensions } = await runtimeEnvironment.runCommand([
    codeCommand,
    "--list-extensions",
  ]);

  await fileOperations.writeTextFile(extensionsFilePath, extensions);

  runtimeEnvironment.log(
    `Extensions have been exported to ${extensionsFilePath}`,
  );
}

function getExtensionsFilePath(
  dependencies: Dependencies = defaultDependencies,
): string {
  const { runtimeEnvironment } = dependencies;
  const dotfilesDirectoryPath = runtimeEnvironment.getEnv("DOTFILES_DIR") ||
    path.join(runtimeEnvironment.getEnv("HOME") || "~", "dotfiles");

  return path.resolve(dotfilesDirectoryPath, "code-extensions");
}

export function showHelp(
  dependencies: Dependencies = defaultDependencies,
): void {
  const { runtimeEnvironment } = dependencies;
  runtimeEnvironment.log(`code-extensions v1.0.0

Usage:
  code-extensions <command>

Commands:
  import    Install extensions from code-extensions file
  export    Export installed extensions to code-extensions file
  help      Show this help message`);
}

export async function main(
  args: string[] = Deno.args,
  dependencies: Dependencies = defaultDependencies,
): Promise<void> {
  const parsedArgs = parseArgs(args);
  const command = parsedArgs._[0];
  const extensionsFilePath = getExtensionsFilePath(dependencies);

  switch (command) {
    case "import":
      await importExtensions(extensionsFilePath, dependencies);
      break;
    case "export":
      await exportExtensions(extensionsFilePath, dependencies);
      break;
    case "help":
    case undefined:
      showHelp(dependencies);
      break;
    default:
      dependencies.runtimeEnvironment.log(`Unknown command: ${command}\n`);
      showHelp(dependencies);
      dependencies.runtimeEnvironment.exit(1);
  }
}

if (import.meta.main) {
  await main();
}
