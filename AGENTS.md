# dotfiles

## Project Overview

P-Chan's portable dev environment as code.

## Directory Structure

- `home/`: Core configuration files, symlinked into the home directory by `mise bootstrap` (see `[dotfiles]` in `home/.config/mise/config.toml`)
  - `.config/`:
    - `zsh/`
    - `tmux/`
    - `vim/`
    - `git/`
    - `ghostty/`
    - `mise/`
    - `gh/`
    - `homebrew/`: Common and profile-specific `Brewfile` definitions
    - `karabiner/`
    - `sheldon/`
    - `zsh-abbr/`
    - `fixpack/`
    - `starship.toml`
  - `.agents/`: Shared AGENTS.md and Agent Skills for coding agents
  - `.claude/`
  - `.codex/`
  - `.ssh/`
  - `.zshenv`
  - `.editorconfig`
- `scripts/`: Scripts for dotfiles operations
- `bin/`: Custom commands for system-wide use

## Tech Stack

- Shell scripts
- Node.js

## Git

- Do not use worktrees in this repository (`convention.use-worktree: false`). Files under `home/` are live configuration referenced via symlinks from the home directory, so changes made in a worktree take no effect. Switch branches in the current working tree instead.

## Verification

- `scripts/doctor.sh`: Check existence of required commands
