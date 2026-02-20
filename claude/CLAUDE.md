# Global Preferences

## Python
Use `uv` (never pip), `ruff`, `pytest`. See `~/.claude/skills/python/` for full preferences.

## SvelteKit
When creating a new SvelteKit project, use `sv create` with these defaults:
```
npx sv create --template minimal --types ts --add prettier tailwindcss="plugins:none" drizzle="database:sqlite+sqlite:better-sqlite3" better-auth="demo:password" eslint --install npm <project-name>
```
Stack: TypeScript, Tailwind CSS, Drizzle (SQLite/better-sqlite3), Better Auth (password), Prettier, ESLint, npm.

## General
- Keep code simple, avoid over-engineering
- Prefer editing existing files over creating new ones
- Small focused functions, logically grouped files
- Think before coding: state assumptions, surface tradeoffs, ask if uncertain
- Review before commit: for non-trivial changes, run `/code-review` before committing
