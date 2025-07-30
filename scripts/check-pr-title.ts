import { echo } from "jsr:@webpod/zx@8.7.1";
import { parseArgs } from "jsr:@std/cli@1.0.21";

const ANGULAR_FLAVORED_CONVENTIONAL_COMMITS_PREFIX_REGEX =
  /^(build|ci|docs|feat|fix|perf|refactor|style|test)(\(.+\))?: .+/;

const args = parseArgs(Deno.args, {
  boolean: ["help", "version"],
  alias: {
    h: "help",
    v: "version",
  },
});

if (args.help) {
  echo("Check PR title with Angular-flavored Conventional Commits-like format");
  echo("");
  echo("Usage:");
  echo("  deno run -A check-pr-title.ts <title>");
  echo("");
  echo("Options:");
  echo("  -h, --help     Show help");
  echo("  -v, --version  Show version");

  Deno.exit(0);
}

if (args.version) {
  echo("check-pr-title 1.0.0");

  Deno.exit(0);
}

if (args._.length === 0) {
  echo("Error: PR title is not specified");

  Deno.exit(1);
}

const title = args._.join(" ");

if (!title) {
  echo("Error: PR title is empty");

  Deno.exit(1);
}

if (!ANGULAR_FLAVORED_CONVENTIONAL_COMMITS_PREFIX_REGEX.test(title)) {
  echo(
    "Error: PR title does not conform to Angular-flavored Conventional Commits-like format"
  );

  Deno.exit(1);
}

const match = title.match(/^([a-z]+)(\(.+\))?: (.+)$/);

if (!match) {
  echo("Error: Title format is incorrect");

  Deno.exit(1);
}

const [, _type, _scope, summary] = match;

if (summary.length === 0) {
  echo("Error: Summary is empty");

  Deno.exit(1);
}

echo("PR title conforms to Angular-flavored Conventional Commits-like format");
