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

## Verification

- `scripts/doctor.sh`: Check existence of required commands
