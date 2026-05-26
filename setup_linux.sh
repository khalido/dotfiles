#!/usr/bin/env bash
#
# Setup script for a fresh Pop!_OS / Ubuntu 24.04 box.
#   curl -fsSL https://raw.githubusercontent.com/khalido/dotfiles/master/setup_linux.sh -o ~/setup_linux.sh
#   bash ~/setup_linux.sh
#
# Mirrors setup_mac.sh in spirit (no `set -e`, idempotent, headers per
# section). No Homebrew. No zsh — Pop!_OS uses bash, the dotfiles' .zshrc
# stays mac-only.
#
# Aimed at modest boxes (X230-class servers / tailscale boxes), so the
# install list is deliberately small. Per-box extras like libusb-dev,
# caddy, ruff are one-line follow-ups, not baked in here.

header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Install a .deb from a GitHub release. Picks the first asset whose
# filename matches `pattern` (PCRE-style regex via jq's `test`). Skips
# if the binary is on PATH.
#   gh_deb_install <binary-name> <owner/repo> <regex>
# Requires jq (installed earlier in the apt step).
gh_deb_install() {
    local cmd="$1" repo="$2" pattern="$3"
    if command -v "$cmd" &>/dev/null; then
        echo "  $cmd: already installed"
        return 0
    fi
    local url
    url=$(curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
          | jq -r --arg pat "$pattern" \
              '.assets[] | select(.name | test($pat)) | .browser_download_url' \
          | head -1)
    if [[ -z "$url" ]]; then
        echo "  $cmd: no asset matching '$pattern' in $repo latest"
        return 1
    fi
    local tmp; tmp=$(mktemp -d)
    echo "  fetching $(basename "$url")..."
    curl -fsSL "$url" -o "$tmp/pkg.deb"
    sudo dpkg -i "$tmp/pkg.deb" 2>&1 | tail -3
    rm -rf "$tmp"
}

header "Pop!_OS / Ubuntu Setup"

# Validate sudo upfront so apt/etc. don't pause mid-install for a password.
# The background loop refreshes the sudo timestamp every 60s so long apt
# runs never re-prompt. Loop dies when the script exits.
echo "This script needs sudo (apt, /etc/* writes). You'll be prompted once."
if ! sudo -v; then
    echo "sudo authentication failed — aborting." >&2
    exit 1
fi
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

header "apt update + essentials"
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    curl wget gnupg ca-certificates \
    git \
    unzip zip \
    usbutils \
    ncurses-term

header "CLI tools (apt)"
# All in Ubuntu 24.04 main. Apt versions of bat/zoxide etc are slightly
# older than upstream but plenty fresh enough for daily use.
sudo apt-get install -y \
    ripgrep fd-find bat \
    jq tree \
    btop \
    ncdu \
    tldr \
    tmux \
    micro \
    fzf \
    git-delta \
    zoxide

# Debian renames: `bat` ships as `batcat`, `fd-find` as `fdfind`. Symlink
# to the conventional names so muscle-memory + docs work everywhere.
mkdir -p ~/.local/bin
[[ -x /usr/bin/batcat && ! -e ~/.local/bin/bat ]] && ln -s /usr/bin/batcat ~/.local/bin/bat
[[ -x /usr/bin/fdfind && ! -e ~/.local/bin/fd ]] && ln -s /usr/bin/fdfind ~/.local/bin/fd

# Make sure ~/.local/bin is on PATH for the rest of this script.
export PATH="$HOME/.local/bin:$PATH"

header "GitHub CLI (apt repo)"
# Curl-based variant of the official wget recipe at
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md — uses
# `tee` (standard) instead of `dd`, and mkdir's both /etc/apt subdirs
# defensively in case we ever land on a stripped image.
if ! command -v gh &>/dev/null; then
    sudo mkdir -p -m 755 /etc/apt/keyrings /etc/apt/sources.list.d
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y gh
else
    echo "  gh: already installed"
fi

header "eza (modern ls) — official apt repo at deb.gierens.de"
if ! command -v eza &>/dev/null; then
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        | sudo tee /etc/apt/sources.list.d/gierens.list > /dev/null
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt-get update
    sudo apt-get install -y eza
else
    echo "  eza: already installed"
fi

header "fastfetch (GitHub release — not in Ubuntu 24.04 apt)"
# fastfetch release assets: linux-amd64.deb (x86_64) / linux-aarch64.deb (arm64).
# `dpkg --print-architecture` gives amd64 / arm64; map arm64 → aarch64 for the URL.
DEB_ARCH=$(dpkg --print-architecture)
[[ "$DEB_ARCH" == "arm64" ]] && FF_ARCH=aarch64 || FF_ARCH=amd64
gh_deb_install fastfetch fastfetch-cli/fastfetch "linux-${FF_ARCH}\.deb\$"

header "starship (prompt)"
if ! command -v starship &>/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
else
    echo "  starship: already installed"
fi

header "Tailscale"
# The official installer handles distro detection + apt repo setup.
if ! command -v tailscale &>/dev/null; then
    curl -fsSL https://tailscale.com/install.sh | sh
else
    echo "  tailscale: already installed"
fi

header "uv (Python)"
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
else
    echo "  uv: already installed"
fi

header "Python tools (via uv)"
# uv tool installs are isolated venvs, so each tool is cheap-ish to add
# without polluting the global Python environment. Stderr is NOT
# suppressed — uv prints progress + "already installed" hints there.
python_tools=(
    harlequin   # terminal SQL client — handy for poking sqlite DBs
    llm         # Simon Willison's LLM CLI — useful interactively + scriptable
)
for tool in "${python_tools[@]}"; do
    uv tool install "$tool"
done

header "Dotfiles"
# Cloned before the Node section so fnm.py is available when fnm runs.
mkdir -p ~/code
if [[ ! -d ~/code/dotfiles ]]; then
    git clone https://github.com/khalido/dotfiles ~/code/dotfiles
else
    echo "  already cloned — pulling latest"
    (cd ~/code/dotfiles && git pull --rebase --autostash 2>&1 | tail -3)
fi

# git config + global gitignore — shell-agnostic, link them.
# (no .zshrc symlink: Linux boxes stay on default bash.)
if [[ -L ~/.gitconfig ]]; then
    echo ".gitconfig: already symlinked"
else
    [[ -f ~/.gitconfig ]] && mv ~/.gitconfig ~/.gitconfig.bak
    ln -s ~/code/dotfiles/.gitconfig ~/.gitconfig
    echo ".gitconfig: linked"
fi
if [[ -L ~/.gitignore_global ]]; then
    echo ".gitignore_global: already symlinked"
else
    ln -s ~/code/dotfiles/.gitignore ~/.gitignore_global
    echo ".gitignore_global: linked"
fi

header "Node.js (via fnm)"
# fnm's installer writes its env into ~/.bashrc automatically (no
# --skip-shell). That's the one bashrc edit we tolerate, since Node has
# to be on PATH for npm to work in new shells.
if ! command -v fnm &>/dev/null; then
    curl -fsSL https://fnm.vercel.app/install | bash
fi
# Load fnm into the current shell so the npm step below works.
export FNM_DIR="$HOME/.local/share/fnm"
[[ -d "$FNM_DIR" ]] && export PATH="$FNM_DIR:$PATH"
eval "$(fnm env 2>/dev/null || true)"

# Pin Node LTS via the shared fnm.py from dotfiles (now cloned above);
# otherwise fall back to plain `fnm install --lts`.
if [[ -f ~/code/dotfiles/fnm.py ]]; then
    uv run ~/code/dotfiles/fnm.py install --yes
else
    fnm install --lts
    fnm default lts-latest
fi

header "Global npm tools"
# Both run fine over SSH:
#   agent-browser drives a headless Chromium for scraping / screenshots
#     (run `agent-browser install` once per box if you actually need
#     Chromium — it's a ~300MB download, not bundled here).
#   opencode-ai is the OpenCode TUI / scriptable CLI — `opencode run "…"`
#     works non-interactively, great over SSH.
npm install -g agent-browser opencode-ai

header "Claude Code"
# Official installer drops the `claude` binary into ~/.local/bin.
# On these boxes we want a default Claude Code install — no skills or
# global CLAUDE.md syncing from dotfiles. If you ever want the workstation
# config on a box, run `uv run ~/code/dotfiles/setup_claude_code.py`.
if ! command -v claude &>/dev/null; then
    curl -fsSL https://claude.ai/install.sh | bash
else
    echo "  claude: already installed"
fi

header "Bash shell integrations"
# Idempotent append to ~/.bashrc — only the bits that need shell wiring
# to actually do anything. fnm + uv already added themselves via their
# own installers; we just handle starship (prompt) + zoxide (smart cd).
# Guarded by the marker comment so re-running the script is a no-op.
if ! grep -q "# setup_linux.sh: shell integrations" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc <<'EOF'

# setup_linux.sh: shell integrations
command -v starship &>/dev/null && eval "$(starship init bash)"
command -v zoxide &>/dev/null && eval "$(zoxide init bash)"
EOF
    echo "  appended starship + zoxide init to ~/.bashrc"
else
    echo "  ~/.bashrc already has the integrations marker"
fi

header "Setup Complete"
cat <<EOF

Next steps:

  1. Authenticate Tailscale + enable SSH on this box:
       sudo tailscale up --ssh
     Visit the one-time URL it prints, approve, and you can SSH in over
     the tailnet without managing authorized_keys.

  2. Open a new shell (or run \`exec bash\`) so fnm/Node land on PATH.

  3. Optional: set timezone if Pop!_OS picked the wrong one:
       sudo timedatectl set-timezone Australia/Sydney

  4. If this box will drive a headless browser (agent-browser):
       agent-browser install        # x86_64: downloads Chrome-for-Testing (~300MB)
     On ARM64 (Pi 5, OrbStack on Apple Silicon) Chrome-for-Testing has no
     Linux build — follow agent-browser's error message to install system
     chromium instead:
       sudo apt install chromium
       agent-browser --executable-path /usr/bin/chromium

What's installed:

  CLI:        ripgrep, fd, bat, jq, tree, btop, ncdu, tldr, tmux,
              micro (editor), fzf, git-delta, zoxide, eza, fastfetch,
              starship (prompt), gh, tailscale
  Python:     uv + harlequin, llm
  Node:       fnm + LTS + agent-browser, opencode-ai
  Claude:     claude (CLI, default config — no dotfiles overlay)
  Dotfiles:   cloned to ~/code/dotfiles; .gitconfig + .gitignore_global linked
  Bash:       ~/.bashrc gets starship + zoxide init appended (one block,
              clearly marked)

Quick checks (in a fresh shell so the bashrc additions are loaded):
  fastfetch         system info splash
  z <dirname>       zoxide jump (after you've cd'd into it once)
  micro <file>      simple modern editor (Ctrl+S save, Ctrl+Q quit)
  opencode run "…"  send a one-shot prompt to OpenCode over SSH
  harlequin foo.db  open a SQLite DB in the terminal

EOF
