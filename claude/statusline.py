#!/usr/bin/env python3
"""Custom status line for Claude Code.

See: https://code.claude.com/docs/en/statusline
"""

import json
import subprocess
import sys
from pathlib import Path

# ANSI colors
BLUE = "\033[34m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED = "\033[31m"
DIM = "\033[2m"
RESET = "\033[0m"


def format_tokens(n):
    """Format token count: 1234 -> 1.2k, 12345 -> 12k"""
    if n >= 10000:
        return f"{n/1000:.0f}k"
    if n >= 1000:
        return f"{n/1000:.1f}k"
    return str(n)


def dir_path(workspace):
    """Short directory path (last 2 parts)."""
    cwd = workspace.get("current_dir") or str(Path.cwd())
    cwd = cwd.replace(str(Path.home()), "~")
    parts = Path(cwd).parts
    short = "/".join(parts[-2:]) if len(parts) > 2 else cwd
    return f"{BLUE}{short}{RESET}"


def git_branch():
    """Git branch via subprocess (handles subdirs, detached HEAD, packed refs)."""
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--abbrev-ref", "HEAD"],
            capture_output=True, text=True, timeout=0.5,
        )
        if result.returncode == 0:
            branch = result.stdout.strip()
            if branch and branch != "HEAD":  # HEAD means detached
                return f" {GREEN}\ue725 {branch}{RESET}"
    except Exception:
        pass
    return ""


def model_name(model):
    """Model display name."""
    if not model:
        return "?"
    if isinstance(model, dict):
        return model.get("display_name") or model.get("id", "?")
    return str(model)


def _context_pct(ctx):
    """Calculate context usage percentage."""
    current = ctx.get("current_usage")
    size = ctx.get("context_window_size", 0)
    if not current or not size:
        return 0
    tokens = (current.get("input_tokens", 0) +
              current.get("cache_creation_input_tokens", 0) +
              current.get("cache_read_input_tokens", 0))
    return int(tokens * 100 / size)


def _heat_color(pct):
    """Get heat color: dim <50%, yellow 50-80%, red >80%."""
    if pct < 50:
        return DIM
    elif pct < 80:
        return YELLOW
    return RED


def context_usage(ctx):
    """Context window usage as percentage with heat colors."""
    pct = _context_pct(ctx)
    color = _heat_color(pct)
    return f"{color}{pct}%{RESET}"


def context_bar(ctx, width=15):
    """Context window usage as visual bar with heat colors. Shows % when > 50%."""
    pct = _context_pct(ctx)
    color = _heat_color(pct)
    filled = int(pct * width / 100)
    empty = width - filled
    bar = "█" * filled + "░" * empty
    # Show exact % when > 50% to help decision-making
    if pct > 50:
        return f"{color}{bar} {pct}%{RESET}"
    return f"{color}{bar}{RESET}"


def session_tokens(ctx):
    """Cumulative session tokens with heat colors based on total usage."""
    tok_in = ctx.get("total_input_tokens", 0)
    tok_out = ctx.get("total_output_tokens", 0)
    total = tok_in + tok_out

    # Heat based on cumulative session usage
    if total < 100_000:
        color = DIM
    elif total < 500_000:
        color = YELLOW
    else:
        color = RED

    return f"{color}{format_tokens(tok_in)}↓ {format_tokens(tok_out)}↑{RESET}"


def cost(cost_data):
    """Formatted cost (dimmed), or empty string if negligible."""
    if not cost_data:
        return ""
    total = cost_data.get("total_cost_usd", 0)
    if total < 0.01:
        return ""
    if total < 1:
        return f" {DIM}${total:.2f}{RESET}"
    return f" {DIM}${total:.1f}{RESET}"


def render(data):
    """Render status line from data dict."""
    ws = data.get("workspace", {})
    ctx = data.get("context_window", {})

    return (
        f"{dir_path(ws)}{git_branch()} {DIM}│{RESET} "
        f"{model_name(data.get('model'))} {DIM}│{RESET} "
        f"{context_bar(ctx)} {DIM}│{RESET} {session_tokens(ctx)}{cost(data.get('cost'))}"
    )


def test():
    """Test status line at different context levels."""
    samples = [
        ("Low (20%)", 40_000, 50_000, 10_000, 0.15),
        ("Medium (55%)", 110_000, 200_000, 40_000, 0.85),
        ("High (85%)", 170_000, 500_000, 100_000, 3.50),
    ]
    for label, ctx_tokens, total_in, total_out, usd in samples:
        data = {
            "model": {"display_name": "Opus"},
            "workspace": {"current_dir": "/Users/test/code/project"},
            "context_window": {
                "context_window_size": 200_000,
                "current_usage": {"input_tokens": ctx_tokens},
                "total_input_tokens": total_in,
                "total_output_tokens": total_out,
            },
            "cost": {"total_cost_usd": usd},
        }
        print(f"{label:12} {render(data)}")


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "--test":
        test()
        return

    try:
        data = json.load(sys.stdin)
        print(render(data), flush=True)
    except Exception:
        fallback = str(Path.cwd()).replace(str(Path.home()), "~")
        print(f"{BLUE}{fallback}{RESET}", flush=True)


if __name__ == "__main__":
    main()
