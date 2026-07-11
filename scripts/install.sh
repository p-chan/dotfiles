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

if ! type mise &>/dev/null; then
  log_info "Installing mise..."

  curl https://mise.run | sh

  log_success "Successfully installed mise."
else
  log_info "mise already installed."
fi

# mise.run installs to ~/.local/bin by default; make it available for the
# rest of this script without requiring a new shell.
export PATH="$HOME/.local/bin:$PATH"

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
  log_info "Running mise bootstrap..."

  mise trust "$DOTFILES_DIR/home/.config/mise/config.toml"

  # macOS GUI provisioning (Dock, Finder, hostname, etc.) doesn't make sense on
  # an ephemeral CI runner, so skip it there like the old provisioning.sh did.
  skip_parts=""
  if [ "$CI" = "true" ]; then
    skip_parts="--skip macos-defaults"
  fi

  DOTFILES_DIR="$DOTFILES_DIR" \
  MISE_GLOBAL_CONFIG_FILE="$DOTFILES_DIR/home/.config/mise/config.toml" \
  mise bootstrap --yes $skip_parts

  log_success "Successfully ran mise bootstrap."
else
  log_warn "mise command not found. Skipping mise bootstrap."
fi
