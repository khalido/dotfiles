# /// script
# requires-python = ">=3.14"
# dependencies = ["typer"]
# ///
"""
fnm.py: Manage Node.js versions via fnm with global package preservation.

Usage:
    uv run fnm.py install       # Fresh install: latest + LTS, set LTS as default
    uv run fnm.py upgrade       # Upgrade and reinstall global packages
    uv run fnm.py status        # Show current state
    uv run fnm.py cleanup       # Remove old versions
"""

import subprocess
import shutil
import json
from typing import Annotated

import typer

app = typer.Typer(
    name="fnm",
    help="Manage Node.js versions via fnm with global package preservation.",
    no_args_is_help=False,
)


def run(cmd: str, capture: bool = True, check: bool = True) -> str:
    """Run a shell command and return stdout."""
    result = subprocess.run(
        cmd,
        shell=True,
        capture_output=capture,
        text=True,
        check=check,
    )
    return result.stdout.strip() if capture else ""


def get_fnm_path() -> str | None:
    """Check if fnm is installed."""
    return shutil.which("fnm")


def is_fnm_from_homebrew() -> bool:
    """Check if fnm was installed via Homebrew."""
    fnm_path = get_fnm_path()
    if fnm_path:
        return "homebrew" in fnm_path.lower() or "/opt/homebrew" in fnm_path
    return False


def get_fnm_version() -> str | None:
    """Get installed fnm version."""
    try:
        output = run("fnm --version")
        # Format: "fnm 1.38.1"
        parts = output.split()
        if len(parts) >= 2:
            return parts[1]
    except subprocess.CalledProcessError:
        pass
    return None


def get_latest_fnm_version() -> str | None:
    """Get latest fnm version from GitHub."""
    try:
        output = run("curl -s https://api.github.com/repos/Schniz/fnm/releases/latest")
        data = json.loads(output)
        tag = data.get("tag_name", "")
        # Format: "v1.38.1" -> "1.38.1"
        return tag.lstrip("v") if tag else None
    except (subprocess.CalledProcessError, json.JSONDecodeError):
        return None


def parse_version(version: str) -> tuple[int, ...]:
    """Parse version string into tuple for comparison."""
    try:
        return tuple(int(x) for x in version.split("."))
    except ValueError:
        return (0,)


def install_fnm(upgrade: bool = False, use_brew: bool | None = None) -> None:
    """Install/upgrade fnm via Homebrew or official installer."""
    # Determine install method: explicit param, or detect from current install, or check brew availability
    if use_brew is None:
        use_brew = is_fnm_from_homebrew() if get_fnm_path() else shutil.which("brew") is not None

    if use_brew:
        if upgrade:
            typer.echo("Upgrading fnm via Homebrew...")
            run("brew upgrade fnm", capture=False)
        else:
            typer.echo("Installing fnm via Homebrew...")
            run("brew install fnm", capture=False)
    else:
        typer.echo("Installing fnm via official installer...")
        run("curl -fsSL https://fnm.vercel.app/install | bash", capture=False)


def ensure_fnm(yes: bool = False, check_update: bool = True) -> None:
    """Ensure fnm is installed and optionally check for updates."""
    if not get_fnm_path():
        typer.echo("fnm not found.")
        has_brew = shutil.which("brew") is not None
        install_method = "Homebrew" if has_brew else "official installer"
        if yes or typer.confirm(f"Install fnm via {install_method}?", default=True):
            install_fnm(use_brew=has_brew)
            typer.echo("fnm installed. Please restart your shell and run this script again.")
            raise typer.Exit(0)
        else:
            typer.echo("Aborted.")
            raise typer.Exit(1)

    # Check for updates
    if check_update:
        current = get_fnm_version()
        latest = get_latest_fnm_version()

        if current and latest and parse_version(current) < parse_version(latest):
            from_brew = is_fnm_from_homebrew()
            source = "Homebrew" if from_brew else "official installer"
            typer.secho(f"fnm update available: {current} -> {latest} ({source})", fg=typer.colors.YELLOW)
            if yes or typer.confirm("Update fnm?", default=True):
                install_fnm(upgrade=True, use_brew=from_brew)
                typer.secho(f"fnm updated to {latest}", fg=typer.colors.GREEN)


def get_default_version() -> str:
    """Get default fnm version."""
    try:
        output = run("fnm list")
        for line in output.splitlines():
            if "default" in line:
                parts = line.replace("*", "").strip().split()
                if parts:
                    return parts[0]
    except subprocess.CalledProcessError:
        pass
    return "none"


def get_installed_versions() -> list[str]:
    """Get list of installed Node.js versions."""
    try:
        output = run("fnm list")
        versions = []
        for line in output.splitlines():
            parts = line.replace("*", "").strip().split()
            if parts and parts[0].startswith("v"):
                versions.append(parts[0])
        return versions
    except subprocess.CalledProcessError:
        return []


def get_global_packages() -> list[str]:
    """Get list of globally installed npm packages (excluding builtins)."""
    try:
        output = run("npm ls -g --depth=0 --json")
        data = json.loads(output)
        deps = data.get("dependencies", {})
        return [pkg for pkg in deps.keys() if pkg not in ("npm", "corepack")]
    except (subprocess.CalledProcessError, json.JSONDecodeError):
        return []


def get_latest_lts() -> str:
    """Get latest LTS version available."""
    output = run("fnm list-remote --lts")
    lines = output.strip().splitlines()
    if lines:
        return lines[-1].split()[0]
    return "unknown"


def get_latest_version() -> str:
    """Get latest Node.js version available (including non-LTS)."""
    output = run("fnm list-remote")
    lines = output.strip().splitlines()
    if lines:
        return lines[-1].split()[0]
    return "unknown"


def get_latest_installed() -> str:
    """Get latest installed Node.js version."""
    versions = get_installed_versions()
    node_versions = [v for v in versions if v.startswith("v")]
    if node_versions:
        sorted_versions = sorted(
            node_versions,
            key=lambda v: tuple(int(x) for x in v[1:].split(".")),
            reverse=True,
        )
        return sorted_versions[0]
    return "none"


def get_latest_installed_lts(installed: list[str]) -> str:
    """Get latest installed LTS version by checking against remote LTS list."""
    try:
        output = run("fnm list-remote --lts")
        lts_versions = {line.split()[0] for line in output.strip().splitlines()}
        installed_lts = [v for v in installed if v in lts_versions]
        if installed_lts:
            sorted_versions = sorted(
                installed_lts,
                key=lambda v: tuple(int(x) for x in v[1:].split(".")),
                reverse=True,
            )
            return sorted_versions[0]
    except subprocess.CalledProcessError:
        pass
    return "none"


def do_install(yes: bool = False) -> tuple[str, str, bool, bool]:
    """
    Core install logic: install latest + LTS, set LTS as default.
    Returns (latest, latest_lts, installed_latest, installed_lts).
    """
    latest = get_latest_version()
    latest_lts = get_latest_lts()
    installed = set(get_installed_versions())

    typer.echo(f"Latest available: {latest}")
    typer.echo(f"Latest LTS: {latest_lts}")

    to_install = []
    if latest not in installed:
        to_install.append(f"{latest} (latest)")
    if latest_lts not in installed:
        to_install.append(f"{latest_lts} (LTS)")

    if to_install:
        typer.echo(f"\nWill install: {', '.join(to_install)}")
    typer.echo(f"Will set default: {latest_lts} (LTS)")

    if not yes and not typer.confirm("\nProceed?", default=True):
        typer.echo("Aborted.")
        raise typer.Exit(0)

    # Install latest (non-LTS) if needed
    installed_latest = False
    if latest not in installed:
        typer.echo(f"\nInstalling {latest}...")
        run(f"fnm install {latest}", capture=False)
        installed_latest = True

    # Install latest LTS if needed
    installed_lts = False
    if latest_lts not in installed:
        typer.echo(f"\nInstalling {latest_lts} (LTS)...")
        run("fnm install --lts", capture=False)
        installed_lts = True

    # Set default to LTS
    typer.echo(f"\nSetting default to {latest_lts}...")
    run("fnm default lts-latest")

    return latest, latest_lts, installed_latest, installed_lts


@app.command()
def status():
    """Show current Node.js status: versions, default, and global packages."""
    ensure_fnm(check_update=False)

    typer.echo("=== fnm status ===\n")

    # fnm version
    fnm_version = get_fnm_version()
    fnm_latest = get_latest_fnm_version()
    fnm_source = "homebrew" if is_fnm_from_homebrew() else "standalone"
    if fnm_version:
        if fnm_latest and parse_version(fnm_version) < parse_version(fnm_latest):
            typer.secho(f"fnm: {fnm_version} ({fnm_source}, update available: {fnm_latest})", fg=typer.colors.YELLOW)
        else:
            typer.echo(f"fnm: {fnm_version} ({fnm_source})")

    versions = get_installed_versions()
    default = get_default_version()
    latest = get_latest_version()
    latest_lts = get_latest_lts()
    packages = get_global_packages()

    typer.echo(f"Installed: {', '.join(versions) if versions else '(none)'}")
    typer.echo(f"Default: {default}")
    typer.echo(f"Latest available: {latest}")
    typer.echo(f"Latest LTS: {latest_lts}")

    if default == latest_lts:
        typer.secho("Up to date!", fg=typer.colors.GREEN)
    elif default == "none":
        typer.secho("No Node.js installed. Run: uv run fnm.py install", fg=typer.colors.YELLOW)
    else:
        typer.secho(f"Update available: {default} -> {latest_lts}", fg=typer.colors.YELLOW)

    typer.echo(f"\nGlobal packages ({len(packages)}):")
    if packages:
        for pkg in packages:
            typer.echo(f"  - {pkg}")
    else:
        typer.echo("  (none)")


@app.command()
def install(
    yes: Annotated[bool, typer.Option("--yes", "-y", help="Skip confirmation")] = False,
):
    """Install latest Node.js and latest LTS, set LTS as default."""
    ensure_fnm(yes)

    typer.echo("=== fnm install ===\n")

    installed = get_installed_versions()
    if installed:
        typer.echo(f"Already installed: {', '.join(installed)}")
        typer.echo("Use 'upgrade' to update existing installation.\n")

    latest, latest_lts, installed_latest, installed_lts = do_install(yes)

    # Summary
    typer.echo("\n" + "=" * 40)
    typer.secho("SUMMARY", bold=True)
    typer.echo("=" * 40)

    if installed_latest:
        typer.secho(f"Installed: {latest}", fg=typer.colors.GREEN)
    else:
        typer.echo(f"Already had: {latest}")
    if installed_lts:
        typer.secho(f"Installed: {latest_lts} (LTS)", fg=typer.colors.GREEN)
    else:
        typer.echo(f"Already had: {latest_lts} (LTS)")

    typer.echo(f"Default: {latest_lts}")
    typer.echo("\nDone! Restart your shell or run: eval \"$(fnm env)\"")


@app.command()
def cleanup(
    yes: Annotated[bool, typer.Option("--yes", "-y", help="Skip confirmation")] = False,
):
    """Remove old Node.js versions, keeping latest installed and latest installed LTS."""
    ensure_fnm()

    versions = get_installed_versions()
    latest_installed = get_latest_installed()
    latest_installed_lts = get_latest_installed_lts(versions)
    default = get_default_version()

    # Keep: latest installed, latest installed LTS, and system
    keep = {latest_installed, latest_installed_lts, "system"}
    to_remove = [v for v in versions if v not in keep]

    typer.echo(f"Installed: {', '.join(versions)}")
    typer.echo(f"Latest installed: {latest_installed}")
    typer.echo(f"Latest installed LTS: {latest_installed_lts}")
    typer.echo(f"Default: {default}")

    if not to_remove:
        typer.echo("\nNo old versions to remove.")
        raise typer.Exit(0)

    typer.echo(f"\nKeeping: {', '.join(sorted(keep - {'system'}))}")
    typer.secho(f"Will remove: {', '.join(to_remove)}", fg=typer.colors.YELLOW)

    # Warn if default will be removed
    if default in to_remove:
        typer.secho(f"\nWarning: Default ({default}) will be removed!", fg=typer.colors.RED)
        typer.echo(f"New default will be set to: {latest_installed_lts}")

    if not yes and not typer.confirm("\nProceed?", default=True):
        typer.echo("Aborted.")
        raise typer.Exit(0)

    # Update default if needed before removing
    if default in to_remove:
        typer.echo(f"\nSetting new default to {latest_installed_lts}...")
        run(f"fnm default {latest_installed_lts}")

    for version in to_remove:
        typer.echo(f"Removing {version}...")
        run(f"fnm uninstall {version}", capture=False, check=False)

    typer.secho(f"\nRemoved {len(to_remove)} version(s).", fg=typer.colors.GREEN)


@app.command()
def upgrade(
    yes: Annotated[bool, typer.Option("--yes", "-y", help="Skip confirmation")] = False,
):
    """Upgrade to latest Node.js versions and reinstall global packages to LTS."""
    ensure_fnm(yes)

    typer.echo("=== fnm upgrade ===\n")

    # Check if any node is installed
    installed = get_installed_versions()
    if not installed:
        typer.echo("No Node.js installed. Running install...\n")
        install(yes=yes)
        return

    old_default = get_default_version()
    typer.echo(f"Current default: {old_default}")

    packages = get_global_packages()
    if packages:
        typer.echo(f"Global packages: {', '.join(packages)}")
    else:
        typer.echo("Global packages: (none)")

    latest = get_latest_version()
    latest_lts = get_latest_lts()
    typer.echo(f"Latest available: {latest}")
    typer.echo(f"Latest LTS: {latest_lts}")

    # Check what needs to be done
    installed_set = set(installed)
    to_install = []
    if latest not in installed_set:
        to_install.append(f"{latest} (latest)")
    if latest_lts not in installed_set:
        to_install.append(f"{latest_lts} (LTS)")

    already_on_lts = old_default == latest_lts

    if not to_install and already_on_lts:
        typer.secho("\nAlready up to date. Nothing to do.", fg=typer.colors.GREEN)
        raise typer.Exit(0)

    # Show what will happen
    typer.echo("\nActions:")
    if to_install:
        typer.echo(f"  Install: {', '.join(to_install)}")
    if not already_on_lts:
        typer.echo(f"  Set default: {old_default} -> {latest_lts}")
    if packages:
        typer.echo(f"  Reinstall {len(packages)} global package(s) to LTS")

    if not yes and not typer.confirm("\nProceed?", default=True):
        typer.echo("Aborted.")
        raise typer.Exit(0)

    # Install latest (non-LTS) if needed
    installed_latest = False
    if latest not in installed_set:
        typer.echo(f"\nInstalling {latest}...")
        run(f"fnm install {latest}", capture=False)
        installed_latest = True

    # Install latest LTS if needed
    installed_lts = False
    if latest_lts not in installed_set:
        typer.echo(f"\nInstalling {latest_lts} (LTS)...")
        run("fnm install --lts", capture=False)
        installed_lts = True

    # Set default to LTS
    if not already_on_lts:
        typer.echo(f"\nSetting default to {latest_lts}...")
        run("fnm default lts-latest")

    # Reinstall global packages to LTS
    reinstalled = []
    failed = []
    if packages:
        typer.echo(f"\nReinstalling {len(packages)} global package(s) to LTS...")
        for pkg in packages:
            try:
                run(f"fnm exec --using=lts-latest npm install -g {pkg}", capture=False)
                reinstalled.append(pkg)
            except subprocess.CalledProcessError:
                failed.append(pkg)
                typer.secho(f"  Failed: {pkg}", fg=typer.colors.RED)

    # Summary
    typer.echo("\n" + "=" * 40)
    typer.secho("SUMMARY", bold=True)
    typer.echo("=" * 40)

    if installed_latest:
        typer.secho(f"Installed: {latest}", fg=typer.colors.GREEN)
    if installed_lts:
        typer.secho(f"Installed: {latest_lts} (LTS)", fg=typer.colors.GREEN)
    if not already_on_lts:
        typer.echo(f"Default: {old_default} -> {latest_lts}")
    else:
        typer.echo(f"Default: {latest_lts} (unchanged)")

    if reinstalled:
        typer.secho(f"Reinstalled: {', '.join(reinstalled)}", fg=typer.colors.GREEN)
    if failed:
        typer.secho(f"Failed: {', '.join(failed)}", fg=typer.colors.RED)
    if not packages:
        typer.echo("No global packages to reinstall.")

    typer.echo("\nDone! Restart your shell or run: eval \"$(fnm env)\"")


@app.callback(invoke_without_command=True)
def main(ctx: typer.Context):
    """
    Manage Node.js versions via fnm with global package preservation.

    fnm is great but doesn't preserve global packages when upgrading.
    This tool handles the full workflow for you.

    Commands:
      install  - Fresh install: latest + LTS, set LTS as default
      upgrade  - Update to latest versions, reinstall global packages
      status   - Show current versions and packages
      cleanup  - Remove old versions, keep latest + latest LTS
    """
    if ctx.invoked_subcommand is None:
        upgrade()


if __name__ == "__main__":
    app()
