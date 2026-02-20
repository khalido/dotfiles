#!/usr/bin/env python3
# /// script
# requires-python = ">=3.14"
# ///
"""
Setup Claude Code config on a new machine.

Usage:
    uv run setup_claude_code.py
"""

from pathlib import Path
import shutil
import sys


def symlink_file(source: Path, target: Path):
    """Create a symlink for a single file, handling existing files."""
    name = target.name
    if target.is_symlink():
        if target.resolve() == source.resolve():
            print(f"  {name}: already linked")
        else:
            target.unlink()
            target.symlink_to(source)
            print(f"  {name}: updated symlink")
    elif target.exists():
        backup = target.with_suffix(target.suffix + ".bak")
        target.rename(backup)
        target.symlink_to(source)
        print(f"  {name}: backed up & linked")
    else:
        target.symlink_to(source)
        print(f"  {name}: linked")


def main():
    dotfiles_claude = Path(__file__).parent.resolve() / "claude"
    claude_home = Path.home() / ".claude"

    print("Setting up Claude Code...")
    print(f"  Source: {dotfiles_claude}")
    print(f"  Target: {claude_home}")

    # Ensure ~/.claude exists
    claude_home.mkdir(exist_ok=True)

    # Symlink skills directory
    skills_source = dotfiles_claude / "skills"
    skills_target = claude_home / "skills"

    if skills_target.is_symlink():
        if skills_target.resolve() == skills_source:
            print("  skills/: already linked")
        else:
            print("  skills/: updating symlink")
            skills_target.unlink()
            skills_target.symlink_to(skills_source)
            print("  skills/: linked")
    elif skills_target.is_dir():
        if any(skills_target.iterdir()):
            print("  skills/: ERROR - directory exists and is not empty")
            print(f"           Backup/remove {skills_target} manually")
            sys.exit(1)
        skills_target.rmdir()
        skills_target.symlink_to(skills_source)
        print("  skills/: linked")
    else:
        skills_target.symlink_to(skills_source)
        print("  skills/: linked")

    # Symlink CLAUDE.md
    symlink_file(dotfiles_claude / "CLAUDE.md", claude_home / "CLAUDE.md")

    # Copy other config files
    files_to_copy = ["settings.json", "statusline.py"]

    for filename in files_to_copy:
        source = dotfiles_claude / filename
        target = claude_home / filename

        if not source.exists():
            continue

        if target.exists():
            # Check if identical
            if target.read_text() == source.read_text():
                print(f"  {filename}: already up to date")
            else:
                print(f"  {filename}: exists (not overwriting)")
        else:
            shutil.copy2(source, target)
            print(f"  {filename}: copied")

    print("Done!")


if __name__ == "__main__":
    main()
