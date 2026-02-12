# Local binaries (e.g. Claude Code)
export PATH="$HOME/.local/bin:$PATH"

# Ensure Homebrew is in PATH early (macOS Apple Silicon)
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
