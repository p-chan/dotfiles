import * as path from "jsr:@std/path@1.1.1";
import { $ } from "jsr:@webpod/zx@8.7.1";
import { parseArgs } from "jsr:@std/cli@1.0.21";

const dotfilesDirectoryPath = Deno.env.get("DOTFILES_DIR");

if (!dotfilesDirectoryPath) {
  console.error("DOTFILES_DIR environment variable is not set.");
  Deno.exit(1);
}

const extensionsFilePath = path.resolve(
  dotfilesDirectoryPath,
  "code-extensions",
);

async function importExtensions() {
  const extensions = (await Deno.readTextFile(extensionsFilePath))
    .split("\n")
    .filter((extension) => extension);

  console.log(`${extensions.length} extensions found to install.\n`);

  const textEncoder = new TextEncoder();

  for (const extension of extensions) {
    await Deno.stdout.write(textEncoder.encode(`Installing ${extension}...`));

    await $`code --install-extension ${extension}`;

    await Deno.stdout.write(
      textEncoder.encode(`\r\x1b[KInstalled ${extension}\n`),
    );
  }

  console.log("\nAll extensions have been installed.");
}

async function exportExtensions() {
  const { stdout: extensions } = await $`code --list-extensions`;

  await Deno.writeTextFile(extensionsFilePath, extensions);

  console.log(`Extensions have been exported to ${extensionsFilePath}`);
}

function showHelp() {
  console.log(`code-extensions v1.0.0

Usage:
  code-extensions <command>

Commands:
  import    Install extensions from code-extensions file
  export    Export installed extensions to code-extensions file
  help      Show this help message`);
}

const args = parseArgs(Deno.args);
const command = args._[0];

switch (command) {
  case "import":
    await importExtensions();
    break;
  case "export":
    await exportExtensions();
    break;
  case "help":
  case undefined:
    showHelp();
    break;
  default:
    console.log(`Unknown command: ${command}\n`);
    showHelp();
    Deno.exit(1);
}
