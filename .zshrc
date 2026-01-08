# Example .zshrc - copy what you need to your actual ~/.zshrc
# (Don't symlink this - real .zshrc has API keys)

# Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# uv / Python tools
export PATH="$HOME/.local/bin:$PATH"

# fnm (Node.js)
eval "$(fnm env)"

# Aliases
alias ll='eza -la'
alias cat='bat'
alias brewup='brew update && brew upgrade'
alias ccu='npx ccusage@latest'
alias ncu='npx npm-check-updates'
alias lt='npx localtunnel --port'  # usage: lt 4000
