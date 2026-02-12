# Dotfiles

macOS/Linux dotfiles managed with GNU Stow.

## Structure

Each top-level directory is a stow package — `stow <pkg>` symlinks its contents into `$HOME`:

- `zsh/` — shell config (zimfw framework)
- `starship/` — prompt config
- `git/` — git config and global ignores

## Key commands

- `./install.sh` — full bootstrap (idempotent, safe to rerun)
- `stow <pkg>` — link a single package
- `stow -D <pkg>` — unlink a package
- `brew bundle --file=Brewfile` — install/update packages

## Conventions

- Stow packages mirror home directory structure (e.g., `starship/.config/starship.toml` → `~/.config/starship.toml`)
- No secrets in this repo — use direnv + 1Password CLI for per-project secrets
- `install.sh` backs up conflicting files to `~/.dotfiles_backup/` before stowing
