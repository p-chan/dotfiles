#!/bin/bash

set -e

DOTFILES_DIR="/workspaces/.codespaces/.persistedshare/dotfiles"

DOTFILES_DIR="$DOTFILES_DIR" bash scripts/install.sh

mkdir -p "$HOME/.config/dotfiles"

echo $DOTFILES_DIR >> "$HOME/.config/dotfiles/dotfiles-dir"
