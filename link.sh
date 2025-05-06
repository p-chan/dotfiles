#!/bin/bash

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/src/github.com/p-chan/dotfiles}"

dotfiles=(
  ".config/fixpack"
  ".config/git"
  ".config/karabiner"
  ".config/mise"
  ".config/vim"
  ".ssh"
  ".editorconfig"
  ".zprofile"
  ".zshenv"
  ".zshrc"
)

for dotfile in "${dotfiles[@]}"; do
  source_file="$DOTFILES_DIR/home/$dotfile"
  destination_file="$HOME/$dotfile"
  destination_parent_dir=$(dirname "$destination_file")

  if [ ! -e "$source_file" ]; then
    echo "$source_file not found. Skipping."

    continue
  fi

  if [ ! -d "$destination_parent_dir" ]; then
    mkdir -p "$destination_parent_dir"
  fi

  if [ ! -e "$destination_file" ]; then
    ln -sv "$source_file" "$destination_file"
  else
    read -n 1 -p "[?] $destination_file already exists. Overwrite? (y/N)" confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      echo ""

      rm -rf "$destination_file"
      ln -sv "$source_file" "$destination_file"
    else
      echo "Skipping override."
    fi;
  fi
done
