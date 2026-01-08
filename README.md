# Dotfiles

Personal config files and setup scripts.

## Quick Start (New Mac)

```bash
# One-liner setup
curl -fsSL https://raw.githubusercontent.com/khalido/dotfiles/main/setup_mac.sh | bash
```

Or clone and run:
```bash
git clone https://github.com/khalido/dotfiles ~/code/dotfiles
bash ~/code/dotfiles/setup_mac.sh
```

## What's Included

### Setup Scripts

- **setup_mac.sh** - Full Mac setup: Homebrew, uv, CLI tools, apps, macOS settings
- **makesymlinks.sh** - Symlink dotfiles (.gitconfig, .zshrc, etc.) to home dir

### Utility Scripts (run with uv)

- **fnm.py** - Node.js version manager helper: install, upgrade, cleanup
- **gitcloneall.py** - Clone all GitHub repos for a user

```bash
uv run fnm.py status      # Check Node.js versions
uv run fnm.py upgrade     # Upgrade Node.js and global packages
uv run gitcloneall.py     # Clone all repos to ~/code
```

### Claude Code Config

The `claude/` directory contains global slash commands and skills for Claude Code.
Symlinked to `~/.claude/commands` and `~/.claude/skills`.

```bash
uv run claude/setup.py    # Setup symlinks on new machine
```

### Dotfiles

- **.gitconfig** - Git configuration
- **.gitignore_global** - Global gitignore
- **.zshrc** - Zsh configuration

## Apps Installed

### CLI (via Homebrew)
bat, eza, ripgrep, fzf, fd, jq, tree, git, gh, fnm, gemini-cli, tlrc, opencode

### Python Tools (via uv)
ruff

### Essential GUI Apps
raycast, firefox, google-chrome, visual-studio-code, zed, ghostty, claude, claude-code, orbstack, monitorcontrol, obsidian

### Manual Installs
- [Chorus](https://chorus.sh/download) - Git client

### Optional GUI Apps
iina, spotify, transmission, keka

## Hyper Key Setup (via Raycast)

Raycast can map Caps Lock to Hyper Key natively (no karabiner needed):

1. Open Raycast Settings → Extensions → Hyper Key
2. Enable and set Caps Lock as the trigger
3. In System Settings → Keyboard → Modifier Keys, ensure Caps Lock is not "No Action"

Example bindings:
```
hyper        : opens raycast
hyper + [    : window left half
hyper + ]    : window right half
hyper + M    : maximize
hyper + L    : lock screen
```
