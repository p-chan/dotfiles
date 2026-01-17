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
    - `Code/`
    - `Code - Insiders/`
    - `sheldon/`
    - `zsh-abbr/`
    - `fixpack/`
    - `starship.toml`
  - `.claude/`
  - `.codex/`
  - `.ssh/`
  - `.zshenv`
  - `.editorconfig`
- `shared/`: Shared configurations across multiple applications
  - `agents/`: Shared by Claude Code and Codex
  - `vscode/`: Shared by VS Code and VS Code Insiders
- `scripts/`: Scripts for dotfiles operations
- `bin/`: Custom commands for system-wide use
- `Brewfile`: Homebrew package definitions
- `code-extensions`: VSCode extensions definitions

## Tech Stack

- Shell scripts
- Deno

## Verification

- `scripts/doctor.sh`: Check existence of required commands
