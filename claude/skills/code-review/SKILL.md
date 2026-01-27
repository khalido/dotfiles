---
name: code-review
description: Review uncommitted changes with fresh context. Use before committing non-trivial work.
user-invocable: true
context: fork
---

# Code Review

Review recently modified code with fresh eyes, looking for bugs, errors, and bad patterns.

## Process

### 1. Understand the Project

Read `CLAUDE.md` and relevant `docs/` to understand patterns, conventions, and gotchas.

### 2. Find and Review Changes

Run `git diff HEAD` (or `git diff HEAD~1` if no uncommitted changes). If changes have already been committed and pushed, review the last 3-5 commits with `git diff HEAD~3..HEAD`.

For each changed file:
1. Read the diff
2. Read enough surrounding context to understand impact
3. Check: does this break any existing callers? (imports, signatures, return types)

### 3. Run Checks

Based on file types:
- Python: `uv run ruff check <files>` and `uv run pytest`
- TypeScript/Svelte: `npm run check`

### 4. Review Checklist

**Correctness**
- Null/undefined/None checks missing
- Off-by-one errors, incorrect conditionals
- Race conditions in async code
- Edge cases: empty input, missing keys, unexpected types
- Do error paths behave sensibly?

**Simplicity**
- Could this do the same thing with less code?
- Abstractions with single implementations?
- Dead code, unused imports, orphaned functions left behind by this change?
- Factory factories, unnecessary inheritance, config for things that won't change?

**Security**
- SQL injection, XSS, command injection
- User input sanitized before file/path/shell operations?
- No secrets or raw exceptions leaked to users?
- Path traversal vectors?

**Consistency**
- Matches existing patterns in the codebase?
- Follows conventions from CLAUDE.md?
- Leftover debug code or TODOs that shouldn't ship?

**Framework-Specific**
- Svelte 5: `$props()` with `$effect()`, `$derived` for reactive values
- Python: `uv run` not `pip`, type hints on signatures, `loguru` for logging

### 5. Push Back When Warranted

Flag if the changes:
- Break existing functionality without updating callers
- Add unnecessary complexity — "could you just do X instead?"
- Violate established codebase patterns
- Skip tests for non-trivial logic

Format: "I'd push back here because [reason]. Suggest instead: [alternative]."

## Report Format

```
## Review: [one-line summary]

### Must Fix
1. **file:line** - Description. Why it matters.

### Should Fix
1. **file:line** - Description. Suggested fix.

### Nits
1. **file:line** - Description.

### Looks Good
[files with no issues]
```

## Rules

- **Report only** — do not auto-fix. User decides what to address.
- **Diff only** — don't review unchanged code unless directly affected.
- **Don't invent issues** — if nothing found, say so.
- **No style nitpicks** that differ from the codebase's own style.
- **Don't flag**: missing abstractions for one-time code, "could be more DRY" for 2-3 lines, missing docs for self-explanatory code, enterprise patterns, premature optimization.
