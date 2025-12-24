#!/bin/bash

is_darwin() {
  [[ "$(uname)" == "Darwin" ]]
}

is_linux() {
  [[ "$(uname)" == "Linux" ]]
}

is_codespaces() {
  [[ "$CODESPACES" == "true" ]]
}

dotfiles=(
  ".claude/CLAUDE.md"
  ".claude/settings.json"
  ".claude/skills"
  ".codex/AGENTS.md"
  ".codex/config.toml"
  ".codex/skills"
  ".config/fixpack"
  ".config/ghostty"
  ".config/git"
  ".config/mise"
  ".config/sheldon"
  ".config/vim"
  ".config/zsh"
  ".config/zsh-abbr"
  ".config/starship.toml"
  ".ssh"
  ".editorconfig"
  ".zshenv"
)

darwin_only_dotfiles=(
  ".config/karabiner"
  "Library/Application Support/Code/User/keybindings.json"
  "Library/Application Support/Code/User/settings.json"
  "Library/Application Support/Code - Insiders/User/keybindings.json"
  "Library/Application Support/Code - Insiders/User/settings.json"
)

linux_only_dotfiles=(
  ".config/Code/User/keybindings.json"
  ".config/Code/User/settings.json"
  ".config/Code - Insiders/User/keybindings.json"
  ".config/Code - Insiders/User/settings.json"
)

if is_darwin; then
  dotfiles+=("${darwin_only_dotfiles[@]}")
fi

if is_linux; then
  dotfiles+=("${linux_only_dotfiles[@]}")
fi

if [ -z "$DOTFILES_DIR" ]; then
  echo "DOTFILES_DIR is not defined"
  exit 1
fi

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
    read -rn 1 -p "[?] $destination_file already exists. Overwrite? (y/N)" confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      echo ""

      rm -rf "$destination_file"
      ln -sv "$source_file" "$destination_file"
    else
      echo "Skipping override."
    fi;
  fi
done
