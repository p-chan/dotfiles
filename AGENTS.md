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

- Do not use worktrees in this repository. Files under `home/` are live configuration referenced via symlinks from the home directory, so changes made in a worktree take no effect. Switch branches in the current working tree instead.

## Confidentiality

This repository is public, but changes are often motivated by problems or findings in other repositories, including private ones. Do not include information about them in this repository. Describe the problem in generic terms instead.

## Verification

- `scripts/doctor.sh`: Check existence of required commands
