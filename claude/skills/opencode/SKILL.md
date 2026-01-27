---
name: opencode
description: Get a second opinion from OpenCode on any question
allowed-tools: Bash(opencode run:*), Read, Glob, Grep
argument-hint: <question or topic>
context: fork
---

Get OpenCode's perspective on: $ARGUMENTS

## Your Task

1. **Gather context**: Find and attach relevant files based on the conversation and "$ARGUMENTS":
   - Always include CLAUDE.md if it exists
   - Add 2-5 most relevant source files
   - Use relative paths when in the same project, absolute paths for cross-project reviews

2. **Summarize** (2-3 sentences): What's the project/problem? What's the current state?

3. **Run OpenCode**:

```bash
opencode run "MESSAGE" -m MODEL -f FILE1 -f FILE2
```

**Syntax rules**: Message MUST come first as a positional arg (quoted string). Flags (`-m`, `-f`) come AFTER the message. Do NOT use `--prompt`.

Example:
```bash
opencode run "Context summary here.

Question: $ARGUMENTS

Give me your honest take - be direct and concise." -m opencode/kimi-k2.5 -f CLAUDE.md -f src/relevant.py
```

## Models

Pick based on task complexity:

| Model | Use for |
|-------|---------|
| `opencode/minimax-m2.1` | Quick questions, lightweight |
| `opencode/glm-4.7` | Evals, comparisons, reviews |
| `opencode/kimi-k2.5` | Default — strong agentic model, good value |
| `opencode/gpt-5.1-codex-mini` | Everyday tasks (cheap) |
| `opencode/gpt-5.2-codex` | Bug checking, 2nd opinions on complex tasks and architecture decisions (paid) |

Default model is `opencode/kimi-k2.5`. Add `-m <model>` to use a different one.

Ref: [OpenCode Zen models](https://opencode.ai/docs/zen/)

## Examples

- `/opencode what do you think of adding caching here?`
- `/opencode kimi how should I structure this feature?`
- `/opencode is this the right approach for auth?`
- `/opencode review this plan as a PM`
- `/opencode codex complex architecture decision here`

## Notes

- This skill runs in a forked context (`context: fork`) to save main conversation space
- Cross-project reviews: use absolute paths (`-f /path/to/other/project/file.md`)
- The second opinion is returned to the main conversation as a summary
