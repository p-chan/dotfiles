import * as path from "jsr:@std/path@1.1.1";
import { $, echo } from "jsr:@webpod/zx@8.7.1";
import { cli, define } from "jsr:@kazupon/gunshi@0.26.3";
import { renderUsage } from "jsr:@kazupon/gunshi@0.26.3/renderer";

const dotfilesDirectoryPath = Deno.env.get("DOTFILES_DIR");

if (!dotfilesDirectoryPath) {
  console.error("DOTFILES_DIR environment variable is not set.");
  Deno.exit(1);
}

const extensionsFilePath = path.resolve(
  dotfilesDirectoryPath,
  "code-extensions"
);

const importCommand = define({
  name: "import",
  run: async () => {
    const extensions = (await Deno.readTextFile(extensionsFilePath))
      .split("\n")
      .filter((extension) => extension);

    echo(`${extensions.length} extensions found to install.\n`);

    for (const extension of extensions) {
      const textEncoder = new TextEncoder();

      await Deno.stdout.write(textEncoder.encode(`Installing ${extension}...`));

      await $`code --install-extension ${extension}`;

      await Deno.stdout.write(
        textEncoder.encode(`\r\x1b[KInstalled ${extension}\n`)
      );
    }

    echo("\nAll extensions have been installed.");
  },
});

const exportCommand = define({
  name: "export",
  run: async () => {
    const { stdout: extensions } = await $`code --list-extensions`;

    await Deno.writeTextFile(extensionsFilePath, extensions);

    echo(`Extensions have been exported to ${extensionsFilePath}`);
  },
});

await cli(
  Deno.args,
  {
    run: async (ctx) => {
      const usage = await renderUsage(ctx);

      echo(usage);
    },
  },
  {
    name: "code-extensions",
    version: "1.0.0",
    subCommands: new Map([
      ["import", importCommand],
      ["export", exportCommand],
    ]),
  }
);
