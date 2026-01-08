#!/usr/bin/env python3
# /// script
# requires-python = ">=3.14"
# dependencies = ["httpx", "typer"]
# ///
"""
Clone all GitHub repos for a user.

Usage:
    uv run gitcloneall.py              # Clone all repos for default user
    uv run gitcloneall.py --user foo   # Clone for a different user
    uv run gitcloneall.py --list       # Just list repos without cloning
"""

import subprocess
from pathlib import Path
from typing import Annotated

import httpx
import typer

app = typer.Typer(help="Clone all GitHub repos for a user.")

DEFAULT_USER = "khalido"
DEFAULT_DIR = Path.home() / "code"


def get_repos(username: str) -> list[dict]:
    """Fetch all public repos for a GitHub user."""
    repos = []
    page = 1
    per_page = 100

    with httpx.Client() as client:
        while True:
            url = f"https://api.github.com/users/{username}/repos"
            response = client.get(url, params={"per_page": per_page, "page": page})
            response.raise_for_status()
            data = response.json()

            if not data:
                break

            repos.extend(data)
            if len(data) < per_page:
                break
            page += 1

    return repos


def clone_repo(clone_url: str, target_dir: Path) -> bool:
    """Clone a repo. Returns True if cloned, False if already exists."""
    repo_name = clone_url.split("/")[-1].replace(".git", "")
    repo_path = target_dir / repo_name

    if repo_path.exists():
        return False

    subprocess.run(["git", "clone", clone_url], cwd=target_dir, check=True)
    return True


@app.command()
def main(
    user: Annotated[str, typer.Option("--user", "-u", help="GitHub username")] = DEFAULT_USER,
    directory: Annotated[Path, typer.Option("--dir", "-d", help="Target directory")] = DEFAULT_DIR,
    list_only: Annotated[bool, typer.Option("--list", "-l", help="List repos only")] = False,
):
    """Clone all public repos for a GitHub user."""
    typer.echo(f"Fetching repos for {user}...")
    repos = get_repos(user)

    if not repos:
        typer.echo("No repos found.")
        raise typer.Exit(1)

    typer.echo(f"Found {len(repos)} repos\n")

    if list_only:
        for repo in sorted(repos, key=lambda r: r["name"].lower()):
            stars = repo.get("stargazers_count", 0)
            desc = repo.get("description", "") or ""
            desc = desc[:50] + "..." if len(desc) > 50 else desc
            typer.echo(f"  {repo['name']:<30} {stars:>3} stars  {desc}")
        return

    directory.mkdir(parents=True, exist_ok=True)

    cloned = 0
    skipped = 0

    for repo in repos:
        name = repo["name"]
        clone_url = repo["clone_url"]

        if clone_repo(clone_url, directory):
            typer.secho(f"  Cloned: {name}", fg=typer.colors.GREEN)
            cloned += 1
        else:
            typer.echo(f"  Exists: {name}")
            skipped += 1

    typer.echo(f"\nDone! Cloned {cloned}, skipped {skipped} (already exist)")


if __name__ == "__main__":
    app()
