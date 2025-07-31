import { parseArgs } from "jsr:@std/cli@1.0.21";

const ANGULAR_FLAVORED_CONVENTIONAL_COMMITS_PREFIX_REGEX =
  /^(build|ci|docs|feat|fix|perf|refactor|style|test)(\(.+\))?: .+/;

type ValidationResult = { valid: true } | { valid: false; error: string };

export function checkTitle(title: string): ValidationResult {
  if (!title) {
    return { valid: false, error: "Error: PR title is empty" };
  }

  if (!ANGULAR_FLAVORED_CONVENTIONAL_COMMITS_PREFIX_REGEX.test(title)) {
    return {
      valid: false,
      error:
        "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    };
  }

  return { valid: true };
}

if (import.meta.main) {
  const args = parseArgs(Deno.args, {
    boolean: ["help", "version"],
    alias: {
      h: "help",
      v: "version",
    },
  });

  if (args.help) {
    console.log(
      "Check PR title with Angular-flavored Conventional Commits-like format"
    );
    console.log("");
    console.log("Usage:");
    console.log("  deno run -A check-pr-title.ts <title>");
    console.log("");
    console.log("Options:");
    console.log("  -h, --help     Show help");
    console.log("  -v, --version  Show version");

    Deno.exit(0);
  }

  if (args.version) {
    console.log("check-pr-title 1.0.0");

    Deno.exit(0);
  }

  if (args._.length === 0) {
    console.error("Error: PR title is not specified");

    Deno.exit(1);
  }

  const title = args._.join(" ");
  const result = checkTitle(title);

  if (!result.valid) {
    console.error(result.error);

    Deno.exit(1);
  }

  console.log(
    "PR title conforms to Angular-flavored Conventional Commits-like format"
  );
}
