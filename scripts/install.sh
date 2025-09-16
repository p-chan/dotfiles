#!/bin/bash

set -e

is_darwin=0

log_info () {
  echo "ℹ️ $1"
}

log_warn () {
  echo "⚠️ $1"
}

log_success () {
  echo "✅ $1"
}

if [[ "$(uname)" == "Darwin" ]]; then
  is_darwin=1

  echo "🍎 Setting up dotfiles on macOS"
fi

if [ -z "$DOTFILES_DIR" ]; then
  echo "DOTFILES_DIR is not defined"
  exit 1
fi

if [ "$is_darwin" -eq 1 ]; then
  if ! pgrep oahd >&/dev/null; then
    log_info "Installing Rosetta 2..."

    sudo softwareupdate --install-rosetta --agree-to-license

    log_success "Successfully installed Rosetta 2."
  else
    log_info "Rosetta 2 already installed."
  fi
fi

if [ "$is_darwin" -eq 1 ]; then
  if ! xcode-select -p &>/dev/null; then
    log_info "Installing Command Line Tools..."

    xcode-select --install

    until xcode-select -p &>/dev/null; do
      sleep 10
    done

    log_success "Successfully installed Command Line Tools."
  else
    log_info "Command Line Tools already installed."
  fi;
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

  sh "$DOTFILES_DIR/scripts/link.sh"

  log_success "Successfully linked dotfiles."
else
  log_warn "$DOTFILES_DIR not found. Skipping dotfiles linking."
fi

if [ "$is_darwin" -eq 1 ]; then
  if ! type brew &>/dev/null; then
    log_info "Installing Homebrew..."

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    log_success "Successfully installed Homebrew."
  else
    log_info "Homebrew already installed."
  fi;
fi;

if [ "$is_darwin" -eq 1 ]; then
  if [ -f /opt/homebrew/bin/brew ]; then
    log_info "Setting up Homebrew."

    eval "$(/opt/homebrew/bin/brew shellenv)"

    log_success "Successfully set up Homebrew."
  else
    log_warn "/opt/homebrew/bin/brew not found. Skipping Homebrew setup."
  fi
fi

if [ "$is_darwin" -eq 1 ]; then
  if type brew &>/dev/null; then
    log_info "Installing Homebrew packages..."

    brew bundle --file="$DOTFILES_DIR/Brewfile"

    log_success "Successfully installed Homebrew packages."
  else
    log_warn "brew command not found. Skipping Homebrew package installation."
  fi
fi

if type mise &>/dev/null; then
  log_info "Installing mise tools..."

  mise install

  log_success "Successfully installed mise tools."
else
  log_warn "mise command not found. Skipping mise tool installation."
fi

if [ "$CI" != "true" ]; then
  if type deno &>/dev/null && type code &>/dev/null; then
    log_info "Installing VSCode extensions..."

    deno run -A "$DOTFILES_DIR/scripts/code-extensions.ts" import

    log_success "Successfully installed VSCode extensions."
  else
    log_warn "deno or code command not found. Skipping VSCode extensions import."
  fi
else
  log_info "CI environment detected. Skipping VSCode extensions import."
fi

if [ "$is_darwin" -eq 1 ]; then
  if [ "$CI" != "true" ]; then
    log_info "Provisioning macOS..."

    sh "$DOTFILES_DIR/scripts/provisioning.sh"

    log_success "Successfully provisioned macOS."
  else
    log_info "CI environment detected. Skipping macOS provisioning."
  fi
fi
