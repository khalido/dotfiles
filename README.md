# Dotfiles

Mac setup scripts and config files. Install apps via Homebrew where available.

## New Mac Setup

Download and run the setup script (installs Homebrew, CLI tools, apps, configures macOS):

```bash
curl -fsSL https://raw.githubusercontent.com/khalido/dotfiles/master/setup_mac.sh -o ~/setup_mac.sh
bash ~/setup_mac.sh
```

After the script completes:

1. **Restart terminal** (or `source ~/.zshrc`)
2. **Restore API keys** - see [Migrate Secrets](#migrate-secrets) below
3. **Sign into apps**: Chrome, Raycast, Obsidian, VS Code (settings sync)
4. **Install Raycast extensions**: Coffee (keep awake), AI (quick questions)

## Migrate Secrets

Transfer `~/.zshrc.local` (API keys) via encrypted zip to Google Drive.

**On old Mac:**
```bash
zip -e ~/Desktop/zshrc.local.zip ~/.zshrc.local
# Enter password when prompted, then move zip to Google Drive
```

**On new Mac:**
```bash
# Download zip from Google Drive to Desktop, then:
unzip ~/Desktop/zshrc.local.zip -d ~
rm ~/Desktop/zshrc.local.zip
source ~/.zshrc
```

## What's Included

### Setup Scripts

- **setup_mac.sh** - Full Mac setup: Homebrew, uv, CLI tools, apps, macOS settings
- **setup_claude_code.py** - Claude Code config: symlinks skills, copies settings
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

The `claude/` directory contains skills and settings for Claude Code.

```bash
uv run setup_claude_code.py    # Run on new machine
```

This will:
- Symlink `claude/skills/` → `~/.claude/skills/`
- Copy `settings.json`, `CLAUDE.md`, `statusline.py` to `~/.claude/`

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
| duckdb | Local SQL analytics |
| tlrc | tldr pages, concise man pages |
| starship | Modern shell prompt |
| cloudflared | Cloudflare tunnels for local dev |
| btop | System monitor |
| jless | Interactive JSON viewer |
| zoxide | Smarter cd command |
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
| cleanshot | Screenshot tool |
| github-desktop | Git GUI |
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
| [Spokenly](https://apps.apple.com/app/spokenly) | Text to speech (App Store) |

### Raycast Extensions

| Extension | Description |
|-----------|-------------|
| Coffee | Keep Mac awake (replaces Amphetamine) |

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
