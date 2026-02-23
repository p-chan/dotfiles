#!/bin/bash

set -e

log_info () {
  echo "ℹ️ $1"
}

log_warn () {
  echo "⚠️ $1"
}

log_success () {
  echo "✅ $1"
}

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/src/github.com/p-chan/dotfiles}"

if ! pgrep oahd >&/dev/null; then
  log_info "Installing Rosetta 2..."

  sudo softwareupdate --install-rosetta --agree-to-license

  log_success "Successfully installed Rosetta 2."
else
  log_info "Rosetta 2 already installed."
fi

if ! xcode-select -p &>/dev/null; then
  log_info "Installing Command Line Tools..."

  xcode-select --install

  until xcode-select -p &>/dev/null; do
    sleep 10
  done

  log_success "Successfully installed Command Line Tools."
else
  log_info "Command Line Tools already installed."
fi

if [ ! -d "$DOTFILES_DIR" ]; then
  log_info "Cloning dotfiles..."

  git clone https://github.com/p-chan/dotfiles.git "$DOTFILES_DIR"

  log_success "Successfully cloned dotfiles."
else
  log_info "dotfiles already cloned."
fi;

if [ -d "$DOTFILES_DIR" ]; then
  log_info "Change remote URL of dotfiles to SSH from HTTPS..."

  cd "$DOTFILES_DIR"

  git remote set-url origin git@github.com:p-chan/dotfiles.git

  cd "$HOME"

  log_success "Successfully changed remote URL of dotfiles."
else
  log_warn "$DOTFILES_DIR not found. Skipping dotfiles remote URL changing."
fi

if [ -d "$DOTFILES_DIR" ]; then
  log_info "Linking dotfiles..."

  DOTFILES_DIR=$DOTFILES_DIR bash "$DOTFILES_DIR/scripts/link.sh"

  log_success "Successfully linked dotfiles."
else
  log_warn "$DOTFILES_DIR not found. Skipping dotfiles linking."
fi

if ! type brew &>/dev/null; then
  log_info "Installing Homebrew..."

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  log_success "Successfully installed Homebrew."
else
  log_info "Homebrew already installed."
fi;

if [ -f /opt/homebrew/bin/brew ]; then
  log_info "Setting up Homebrew."

  eval "$(/opt/homebrew/bin/brew shellenv)"

  log_success "Successfully set up Homebrew."
else
  log_warn "/opt/homebrew/bin/brew not found. Skipping Homebrew setup."
fi

if type brew &>/dev/null; then
  log_info "Installing Homebrew packages..."

  brew bundle --file="$DOTFILES_DIR/Brewfile"

  log_success "Successfully installed Homebrew packages."
else
  log_warn "brew command not found. Skipping Homebrew package installation."
fi

if type mise &>/dev/null; then
  log_info "Installing mise tools..."

  mise install

  eval "$(mise env -s bash)"

  log_success "Successfully installed mise tools."
else
  log_warn "mise command not found. Skipping mise tool installation."
fi

if type ya &>/dev/null; then
  log_info "Installing yazi plugins and flavors..."

  while IFS= read -r package; do
    [[ -z "$package" || "$package" == \#* ]] && continue
    ya pkg add "$package"
  done < "$DOTFILES_DIR/home/.config/yazi/packages.txt"

  log_success "Successfully installed yazi plugins and flavors."
else
  log_warn "ya command not found. Skipping yazi plugins and flavors installation."
fi

if ! type claude &>/dev/null; then
  log_info "Installing Claude Code..."

  curl -fsSL https://claude.ai/install.sh | bash

  log_success "Successfully installed Claude Code."
else
  log_info "Claude Code already installed."
fi

if type gh &>/dev/null; then
  log_info "Installing gh extensions..."

  while IFS= read -r extension; do
    [[ -z "$extension" || "$extension" == \#* ]] && continue
    gh extension install "$extension"
  done < "$DOTFILES_DIR/gh-extensions"

  log_success "Successfully installed gh extensions."
else
  log_warn "gh command not found. Skipping gh extensions installation."
fi

if [ "$CI" != "true" ]; then
  if type deno &>/dev/null; then
    if type code &>/dev/null; then
      log_info "Installing VSCode extensions for VSCode..."

      DOTFILES_DIR=$DOTFILES_DIR deno run -A "$DOTFILES_DIR/scripts/code-extensions.ts" import

      log_success "Successfully installed VSCode extensions for VSCode."
    else
      log_warn "code command not found. Skipping VSCode extensions import."
    fi
  else
    log_warn "deno command not found. Skipping VSCode extensions import."
  fi
else
  log_info "CI environment detected. Skipping VSCode extensions import."
fi

if [ "$CI" != "true" ]; then
  log_info "Provisioning macOS..."

  bash "$DOTFILES_DIR/scripts/provisioning.sh"

  log_success "Successfully provisioned macOS."
else
  log_info "CI environment detected. Skipping macOS provisioning."
fi
