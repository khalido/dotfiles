#!/usr/bin/env bash
#
# Setup script for a new Mac
# Run: curl -fsSL https://raw.githubusercontent.com/khalido/dotfiles/main/setup_mac.sh | bash
# Or:  bash setup_mac.sh

set -e

header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

header "Mac Setup Script"

# Ask for sudo upfront
sudo -v

# Keep sudo alive
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

header "Xcode CLI Tools"
xcode-select --install 2>/dev/null || echo "Already installed"

header "Homebrew"
if ! command -v brew &>/dev/null; then
    echo "Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "Already installed"
fi
brew update

header "uv (Python)"
if ! command -v uv &>/dev/null; then
    echo "Installing..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Add to path for this session
    export PATH="$HOME/.local/bin:$PATH"
else
    echo "Already installed"
fi

header "CLI Tools"
cli_apps=(
    # Core utils
    bat         # better cat with syntax highlighting
    eza         # modern ls with colors/icons
    ripgrep     # fast grep replacement
    fzf         # fuzzy finder for everything
    fd          # fast find replacement
    jq          # JSON processor
    tree        # directory tree view

    # Dev tools
    git
    gh          # GitHub CLI for PRs/issues
    fnm         # fast Node.js version manager

    # AI tools
    gemini-cli  # Google Gemini in terminal

    # Nice to have
    tlrc        # tldr pages, concise man pages
)

for app in "${cli_apps[@]}"; do
    brew install "$app" 2>/dev/null || echo "  $app: already installed"
done

# OpenCode (AI coding assistant)
brew tap anomalyco/tap 2>/dev/null || true
brew install anomalyco/tap/opencode 2>/dev/null || echo "  opencode: already installed"

header "Python Tools (via uv)"
uv tool install ruff@latest 2>/dev/null || echo "  ruff: already installed"

header "Node.js (via fnm)"
if [[ -f ~/code/dotfiles/fnm.py ]]; then
    uv run ~/code/dotfiles/fnm.py install --yes
else
    # Fallback if dotfiles not cloned yet
    eval "$(fnm env)"
    fnm install --lts
    fnm default lts-latest
fi

header "Essential Apps"
essential_apps=(
    # Launcher (also handles hyperkey + window management)
    raycast

    # Browsers
    firefox
    google-chrome

    # Coding
    visual-studio-code
    zed
    ghostty
    claude
    claude-code

    # Dev tools
    orbstack        # Docker/VMs, fast & light

    # Utilities
    monitorcontrol  # external monitor brightness/volume

    # Notes
    obsidian
)

# Manual installs (no brew cask):
# - Chorus (Git client): https://chorus.sh/download

for app in "${essential_apps[@]}"; do
    brew install --cask "$app" 2>/dev/null || echo "  $app: already installed"
done

header "Optional Apps"
optional_apps=(
    iina            # elegant media player
    spotify         # music streaming
    transmission    # torrent client
    keka            # file archiver
)

for app in "${optional_apps[@]}"; do
    brew install --cask "$app" 2>/dev/null || echo "  $app: already installed"
done

brew cleanup

header "Dotfiles"
mkdir -p ~/code
if [[ ! -d ~/code/dotfiles ]]; then
    echo "Cloning dotfiles..."
    git clone https://github.com/khalido/dotfiles ~/code/dotfiles
else
    echo "Already cloned"
fi

# Setup Claude Code symlinks
if [[ -f ~/code/dotfiles/claude/setup.py ]]; then
    echo "Setting up Claude Code config..."
    uv run ~/code/dotfiles/claude/setup.py
fi

header "macOS Settings"

# Password after sleep
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Disable smart quotes/dashes (annoying for code)
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Full keyboard access
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable extension change warning
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Column view in Finder
defaults write com.apple.finder FXPreferredViewStyle Clmv

# Don't create .DS_Store on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Dock: auto-hide, smaller icons
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0.2

# Trackpad: tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Screenshots to Desktop as PNG
defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture type -string "png"

echo "Applied settings"

killall Finder 2>/dev/null || true
killall Dock 2>/dev/null || true

header "Setup Complete!"
echo ""
echo "Next steps:"
echo "  1. Restart terminal (or run: source ~/.zshrc)"
echo "  2. Set Raycast as hyperkey: Raycast Settings → Extensions → Hyper Key"
echo "  3. Sign in to apps (Chrome, VS Code, etc.)"
echo ""
