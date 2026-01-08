# Claude Code Configuration

Global slash commands and skills for Claude Code, synced via dotfiles.

## Structure

```
claude/
├── commands/    # Slash commands (user-invoked with /command-name)
├── skills/      # Skills (Claude auto-invokes when relevant)
├── setup.py     # Setup script for new machines
└── README.md
```

## Setup on a New Machine

Requires [uv](https://docs.astral.sh/uv/) installed.

```bash
# Clone dotfiles repo (if not already)
git clone https://github.com/khalido/dotfiles ~/code/dotfiles

# Run setup script
uv run ~/code/dotfiles/claude/setup.py
```

## Creating Commands & Skills

### Slash Commands (`commands/`)

Markdown files invoked with `/name`. Example `commands/hello.md`:

```markdown
---
argument-hint: "[name]"
---
Say hello to $ARGUMENTS
```

Subdirectories create namespaces: `commands/git/sync.md` → `/git:sync`

### Skills (`skills/`)

Markdown files Claude can auto-invoke. Example `skills/translate.md`:

```markdown
---
description: Opens Google Translate for pronunciation
user-invocable: true
---
When asked about pronunciation, open translate.google.com with the word.
```

Key frontmatter options:
- `context: fork` - Run in isolated context
- `user-invocable: false` - Hide from slash menu (Claude-only)
- `allowed-tools: [Read, Bash(git *)]` - Restrict tool access

## Manual Symlink Setup

If you prefer not to use the script:

```bash
# Remove existing dirs if present
rm -rf ~/.claude/commands ~/.claude/skills

# Create symlinks
ln -s ~/code/dotfiles/claude/commands ~/.claude/commands
ln -s ~/code/dotfiles/claude/skills ~/.claude/skills
```
