# Example .zshrc - copy what you need to your actual ~/.zshrc

# Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# uv / Python tools
export PATH="$HOME/.local/bin:$PATH"

# fnm (Node.js)
eval "$(fnm env)"

# Starship prompt
eval "$(starship init zsh)"

# Editor (for Claude Code Ctrl+G, git, etc)
export EDITOR="zed --wait"

# Aliases
alias ll='eza -la'
alias cat='bat'
alias brewup='brew update && brew upgrade'
alias ccu='npx ccusage@latest'
alias ncu='npx npm-check-updates'

# Cloudflare tunnel - usage: tunnel 8000
tunnel() { cloudflared tunnel --url http://localhost:${1:-8000}; }

# Load local secrets (API keys, tokens)
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
