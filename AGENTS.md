# dotfiles

## Project Overview

P-Chan's portable dev environment as code.

## Directory Structure

- `home/`: Core configuration files to be symlinked to home directory with `scripts/link.sh`
  - `.config/`:
    - `zsh/`
    - `tmux/`
    - `vim/`
    - `git/`
    - `ghostty/`
    - `mise/`
    - `gh/`
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
- `Brewfile`: Homebrew package definitions
- `code-extensions`: VSCode extensions definitions

## Tech Stack

- Shell scripts
- Deno

## Git

- Do not use worktrees in this repository (`convention.use-worktree: false`). Files under `home/` are live configuration referenced via symlinks from the home directory, so changes made in a worktree take no effect. Switch branches in the current working tree instead.

## Verification

- `scripts/doctor.sh`: Check existence of required commands
