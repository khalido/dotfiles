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

- **.gitconfig** - Git configuration (symlinked)
- **.gitignore_global** - Global gitignore (symlinked)
- **.zshrc** - Shell config (symlinked; secrets go in ~/.zshrc.local)

## Apps Installed

### CLI Tools (Homebrew)

| App | Description |
|-----|-------------|
| bat | Better cat with syntax highlighting |
| eza | Modern ls with colors/icons |
| ripgrep | Fast grep replacement |
| fzf | Fuzzy finder for everything |
| fd | Fast find replacement |
| jq | JSON processor |
| tree | Directory tree view |
| git | Version control |
| gh | GitHub CLI for PRs/issues |
| fnm | Fast Node.js version manager |
| gemini-cli | Google Gemini in terminal |
| tlrc | tldr pages, concise man pages |
| starship | Modern shell prompt |
| cloudflared | Cloudflare tunnels for local dev |
| opencode | AI coding assistant (via tap) |

### GUI Apps - Essential (Homebrew Casks)

| App | Description |
|-----|-------------|
| raycast | Launcher + hyperkey + window management |
| firefox | Browser |
| google-chrome | Browser |
| visual-studio-code | Code editor |
| zed | Fast native code editor |
| ghostty | GPU-accelerated terminal |
| claude | Claude desktop app |
| claude-code | Claude Code CLI |
| orbstack | Docker/VMs, fast & light |
| coteditor | Fast native text editor |
| monitorcontrol | External monitor brightness/volume |
| font-fira-code-nerd-font | Nerd font for starship/terminal icons |
| obsidian | Notes |

### GUI Apps - Optional (Homebrew Casks)

| App | Description |
|-----|-------------|
| iina | Elegant media player |
| spotify | Music streaming |
| transmission | Torrent client |
| keka | File archiver |

### Python Tools (uv)

| Tool | Description |
|------|-------------|
| ruff | Linter/formatter |
| harlequin | Terminal SQL client |
| posting | Terminal API client (like Postman) |
| llm | Simon Willison's LLM CLI |

### Manual Installs

| App | Description |
|-----|-------------|
| [Chorus](https://chorus.sh/download) | Git client (no brew cask) |

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
