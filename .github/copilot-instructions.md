# Review Guidelines

## Comment Prefixes

When writing Pull Request review comments, always use one of the following prefixes.

### Prefix Types

- **MUST**: Critical issues that must be fixed (security, bugs, specification violations, etc.)
- **SHOULD**: Recommended changes (performance, maintainability, best practices, etc.)
- **IMO**: Personal opinions or suggestions (In My Opinion)
- **NITS**: Minor issues (typos, formatting, small naming improvements, etc.)

### Examples

```
MUST: This implementation may introduce an XSS vulnerability. Please add input escaping.

SHOULD: This process can be parallelized using Promise.all.

IMO: I think `userData` would be a clearer variable name here.

NITS: Indentation is inconsistent.
```
