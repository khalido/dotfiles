#!/usr/bin/env python3
# /// script
# requires-python = ">=3.14"
# ///
"""
Setup Claude Code symlinks for commands and skills.

Usage:
    uv run setup.py
"""

from pathlib import Path
import sys


def main():
    dotfiles_claude = Path(__file__).parent.resolve()
    claude_home = Path.home() / ".claude"

    symlinks = {
        "commands": dotfiles_claude / "commands",
        "skills": dotfiles_claude / "skills",
    }

    print(f"Setting up Claude Code symlinks...")
    print(f"  Source: {dotfiles_claude}")
    print(f"  Target: {claude_home}")

    # Ensure ~/.claude exists
    claude_home.mkdir(exist_ok=True)

    for name, source in symlinks.items():
        target = claude_home / name

        if target.is_symlink():
            current = target.resolve()
            if current == source:
                print(f"  {name}: already linked correctly")
                continue
            else:
                print(f"  {name}: updating symlink (was {current})")
                target.unlink()
        elif target.is_dir():
            if any(target.iterdir()):
                print(f"  {name}: ERROR - directory exists and is not empty")
                print(f"         Please backup/remove {target} manually")
                sys.exit(1)
            target.rmdir()
            print(f"  {name}: removed empty directory")
        elif target.exists():
            print(f"  {name}: ERROR - unexpected file exists at {target}")
            sys.exit(1)

        target.symlink_to(source)
        print(f"  {name}: linked")

    print("Done!")


if __name__ == "__main__":
    main()
