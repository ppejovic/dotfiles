#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

info() { printf '\033[34m[info]\033[0m %s\n' "$1"; }
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

# --- Stow packages ---
info "Linking dotfiles with stow..."
cd "$DOTFILES_DIR"
stow -v --target="$HOME" zsh starship git

# --- Install zimfw ---
ZIM_HOME="$HOME/.zim"
if [[ ! -d "$ZIM_HOME" ]]; then
  info "Installing zimfw..."
  curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.sh | zsh
else
  info "zimfw already installed"
fi

# Install/update zimfw modules
info "Installing zimfw modules..."
zsh -ilc 'zimfw install'

info "Done! Open a new terminal to see your new shell."
