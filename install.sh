#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

info() { printf '\033[34m[info]\033[0m %s\n' "$1"; }
warn() { printf '\033[33m[warn]\033[0m %s\n' "$1"; }
error() { printf '\033[31m[error]\033[0m %s\n' "$1" >&2; exit 1; }

# --- Detect environment ---
OS="$(uname -s)"

# --- Install packages ---
if [[ "$OS" == "Darwin" ]]; then
  info "macOS detected"

  # Install Homebrew if missing
  if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  fi

  info "Running brew bundle..."
  brew bundle --file="$DOTFILES_DIR/Brewfile"

elif [[ "$OS" == "Linux" ]]; then
  info "Linux detected"

  # Install stow
  if ! command -v stow &>/dev/null; then
    info "Installing stow..."
    sudo apt-get update && sudo apt-get install -y stow
  fi

  # Install starship
  if ! command -v starship &>/dev/null; then
    info "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
  fi

  # Install direnv
  if ! command -v direnv &>/dev/null; then
    info "Installing direnv..."
    sudo apt-get install -y direnv 2>/dev/null || {
      curl -sfL https://direnv.net/install.sh | bash
    }
  fi

else
  error "Unsupported OS: $OS"
fi

# --- Back up conflicting files ---
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
STOW_PACKAGES=(zsh starship git)

conflicts=()
for pkg in "${STOW_PACKAGES[@]}"; do
  while IFS= read -r file; do
    target="$HOME/$file"
    if [[ -e "$target" && ! -L "$target" ]]; then
      conflicts+=("$target")
    fi
  done < <(cd "$DOTFILES_DIR/$pkg" && find . -type f | sed 's|^\./||')
done

if [[ ${#conflicts[@]} -gt 0 ]]; then
  info "Backing up existing files to $BACKUP_DIR"
  mkdir -p "$BACKUP_DIR"
  for file in "${conflicts[@]}"; do
    rel="${file#$HOME/}"
    mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
    mv "$file" "$BACKUP_DIR/$rel"
    info "  backed up $rel"
  done
fi

# --- Stow packages ---
info "Linking dotfiles with stow..."
cd "$DOTFILES_DIR"
stow -v --no-folding --target="$HOME" "${STOW_PACKAGES[@]}"

# --- Install zimfw ---
ZIM_HOME="$HOME/.zim"
if [[ ! -f "$ZIM_HOME/zimfw.zsh" ]]; then
  info "Installing zimfw..."
  mkdir -p "$ZIM_HOME"
  curl -fsSL -o "$ZIM_HOME/zimfw.zsh" https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
else
  info "zimfw already installed"
fi

# Install/update zimfw modules
info "Installing zimfw modules..."
zsh -lc 'ZIM_HOME=~/.zim source ~/.zim/zimfw.zsh install'

# --- Install Claude Code ---
if ! command -v claude &>/dev/null; then
  info "Installing Claude Code..."
  curl -fsSL https://claude.ai/install.sh | bash
else
  info "Claude Code already installed"
fi

# --- GitHub CLI auth ---
if command -v gh &>/dev/null && ! gh auth status &>/dev/null; then
  warn "GitHub CLI installed but not authenticated. Run: gh auth login"
fi

info "Done! Open a new terminal to see your new shell."
