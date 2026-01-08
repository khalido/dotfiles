---
description: Get a second opinion from OpenCode on any question
allowed-tools: Bash(opencode run:*), Read, Glob, Grep
argument-hint: <question or topic>
---

Get OpenCode's perspective on: $ARGUMENTS

## Your task

1. **Gather context**: Find and attach relevant files based on the conversation and "$ARGUMENTS":
   - Always include CLAUDE.md if it exists
   - Add 2-7 most relevant source files
   - Use relative paths from project root

2. **Summarize** (2-3 sentences): What's the project/problem? What's the current state?

3. **Run OpenCode**:

```bash
opencode run "[Your 2-3 sentence context summary]

Question: $ARGUMENTS

Give me your honest take - be direct and concise." -f CLAUDE.md -f src/relevant.py -f src/other.py
```

## Models

Pick based on task complexity:

| Model | Use for |
|-------|---------|
| `opencode/minimax-m2.1-free` | Default, quick questions (free) |
| `opencode/glm-4.7-free` | Evals, comparisons (free) |
| `opencode/grok-code` | Decent general use |
| `opencode/gpt-5.1-codex-mini` | Everyday tasks (cheap) |
| `opencode/gpt-5.1-codex-max` | Complex problems (paid) |

User can request a model: `/opencode grok should I use X or Y?` → use `opencode/grok-code`

Add `-m <model>` to the command if specified.

## Examples

- `/opencode what do you think of adding caching here?`
- `/opencode grok how should I structure this feature?`
- `/opencode is this the right approach for auth?`
