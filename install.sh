#!/bin/bash

set -e

DOTFILES_DIR="/workspaces/.codespaces/.persistedshare/dotfiles"

DOTFILES_DIR="$DOTFILES_DIR" bash scripts/install.sh

echo $DOTFILES_DIR >> "$HOME/.config/dotfiles/dotfiles-dir"
