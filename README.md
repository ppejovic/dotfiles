# Dotfiles

Personal dotfiles for **macOS**, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's included

| Package | Contents |
|---------|----------|
| `zsh/` | Shell config ([zimfw](https://zimfw.sh/) framework) |
| `starship/` | [Starship](https://starship.rs/) prompt config |
| `git/` | Git config and global ignores |

Plus a `Brewfile` for macOS packages and an `install.sh` bootstrap script.

## Setup

```bash
git clone https://github.com/ppejovic/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The install script is idempotent and safe to rerun. It will:

1. Install Homebrew (if missing)
2. Install packages from the Brewfile (stow, starship, direnv, gh, etc.)
3. Back up any conflicting files to `~/.dotfiles_backup/`
4. Symlink dotfiles into `$HOME` via Stow
5. Install zimfw and its modules
6. Install Claude Code

## Managing packages

```bash
stow <pkg>       # link a package
stow -D <pkg>    # unlink a package
```

Stow packages mirror the home directory structure, e.g. `starship/.config/starship.toml` links to `~/.config/starship.toml`.
