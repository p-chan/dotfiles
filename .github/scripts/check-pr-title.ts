const ANGULAR_FLAVORED_CONVENTIONAL_COMMITS_PREFIX_REGEX =
  /^(build|chore|ci|docs|feat|fix|perf|refactor|style|test)(\(.+\))?: \S.*/;

type ValidationResult = { valid: true } | { valid: false; error: string };

export function checkTitle(title: string): ValidationResult {
  if (!title) {
    return { valid: false, error: "Error: PR title is empty" };
  }

  if (!ANGULAR_FLAVORED_CONVENTIONAL_COMMITS_PREFIX_REGEX.test(title)) {
    return {
      valid: false,
      error: "Error: PR title does not conform to Angular-flavored Conventional Commits-like format",
    };
  }

  return { valid: true };
}

if (import.meta.main) {
  const args = process.argv.slice(2);

  if (args.includes("-h") || args.includes("--help")) {
    console.log("Check PR title with Angular-flavored Conventional Commits-like format");
    console.log("");
    console.log("Usage:");
    console.log("  node check-pr-title.ts <title>");
    console.log("");
    console.log("Options:");
    console.log("  -h, --help     Show help");
    console.log("  -v, --version  Show version");
  } else if (args.includes("-v") || args.includes("--version")) {
    console.log("check-pr-title 1.0.0");
  } else if (args.length === 0) {
    console.error("Error: PR title is not specified");
    process.exitCode = 1;
  } else {
    const result = checkTitle(args.join(" "));

    if (!result.valid) {
      console.error(result.error);
      process.exitCode = 1;
    } else {
      console.log("PR title conforms to Angular-flavored Conventional Commits-like format");
    }
  }
}
