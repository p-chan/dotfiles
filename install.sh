#!/bin/bash

set -e

dotfiles_dir="$DOTFILES_DIR"

is_darwin() {
  [[ "$(uname)" == "Darwin" ]]
}

is_linux() {
  [[ "$(uname)" == "Linux" ]]
}

is_codespaces() {
  [[ "$CODESPACES" == "true" ]]
}

log_info () {
  echo "ℹ️ $1"
}

log_warn () {
  echo "⚠️ $1"
}

log_success () {
  echo "✅ $1"
}

if is_darwin; then
  echo "🍎 Setting up dotfiles on macOS"
fi

if is_linux; then
  echo "🐧 Setting up dotfiles on Linux"
fi

if is_codespaces; then
  dotfiles_dir="/workspaces/.codespaces/.persistedshare/dotfiles"
fi

if [ -z "$dotfiles_dir" ]; then
  echo "dotfiles_dir is not defined"
  exit 1
fi

if is_darwin; then
  if ! pgrep oahd >&/dev/null; then
    log_info "Installing Rosetta 2..."

    sudo softwareupdate --install-rosetta --agree-to-license

    log_success "Successfully installed Rosetta 2."
  else
    log_info "Rosetta 2 already installed."
  fi
fi

if is_darwin; then
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

if [ ! -d "$dotfiles_dir" ]; then
  log_info "Cloning dotfiles..."

  git clone https://github.com/p-chan/dotfiles.git "$dotfiles_dir"

  log_success "Successfully cloned dotfiles."
else
  log_info "dotfiles already cloned."
fi;

if [ -d "$dotfiles_dir" ]; then
  log_info "Change remote URL of dotfiles to SSH from HTTPS..."

  cd "$dotfiles_dir"

  git remote set-url origin git@github.com:p-chan/dotfiles.git

  cd "$HOME"

  log_success "Successfully changed remote URL of dotfiles."
else
  log_warn "$dotfiles_dir not found. Skipping dotfiles remote URL changing."
fi

if [ -d "$dotfiles_dir" ]; then
  log_info "Linking dotfiles..."

  DOTFILES_DIR=$dotfiles_dir bash "$dotfiles_dir/scripts/link.sh"

  log_success "Successfully linked dotfiles."
else
  log_warn "$dotfiles_dir not found. Skipping dotfiles linking."
fi

if is_darwin; then
  if ! type brew &>/dev/null; then
    log_info "Installing Homebrew..."

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    log_success "Successfully installed Homebrew."
  else
    log_info "Homebrew already installed."
  fi;
fi;

if is_darwin; then
  if [ -f /opt/homebrew/bin/brew ]; then
    log_info "Setting up Homebrew."

    eval "$(/opt/homebrew/bin/brew shellenv)"

    log_success "Successfully set up Homebrew."
  else
    log_warn "/opt/homebrew/bin/brew not found. Skipping Homebrew setup."
  fi
fi

if is_darwin; then
  if type brew &>/dev/null; then
    log_info "Installing Homebrew packages..."

    brew bundle --file="$dotfiles_dir/Brewfile"

    log_success "Successfully installed Homebrew packages."
  else
    log_warn "brew command not found. Skipping Homebrew package installation."
  fi
fi

if is_linux; then
  if ! type zsh &>/dev/null; then
    log_info "Installing zsh..."

    sudo apt update
    sudo apt install -y zsh

    log_success "Successfully installed zsh."
  else
    log_info "zsh already installed."
  fi;

  if [ "$CI" != "true" ] && ! is_codespaces; then
    log_info "Changing default shell to zsh..."

    chsh -s "$(command -v zsh)" "$(whoami)"

    log_success "Successfully changed default shell to zsh (will take effect on next login)."
  fi;
fi;

if is_linux; then
  if ! type mise &>/dev/null; then
    log_info "Installing mise..."

    curl https://mise.run | sh

    log_success "Successfully installed mise."
  else
    log_info "mise already installed."
  fi;
fi;

if type mise &>/dev/null; then
  log_info "Installing mise tools..."

  eval "$(mise env -s bash)"

  mise install

  log_success "Successfully installed mise tools."
else
  log_warn "mise command not found. Skipping mise tool installation."
fi

if is_codespaces; then
  echo "Checking code and deno in Codespaces..."
  type code || echo "code not found"
  which code || echo "code not in PATH"

  type deno || echo "deno not found"
  which deno || echo "deno not in PATH"

  echo "PATH=$PATH"
fi

if [ "$CI" != "true" ]; then
  if type deno &>/dev/null && type code &>/dev/null; then
    log_info "Installing VSCode extensions..."

    deno run -A "$dotfiles_dir/scripts/code-extensions.ts" import

    log_success "Successfully installed VSCode extensions."
  else
    log_warn "deno or code command not found. Skipping VSCode extensions import."
  fi
else
  log_info "CI environment detected. Skipping VSCode extensions import."
fi

if is_darwin; then
  if [ "$CI" != "true" ]; then
    log_info "Provisioning macOS..."

    bash "$dotfiles_dir/scripts/provisioning.sh"

    log_success "Successfully provisioned macOS."
  else
    log_info "CI environment detected. Skipping macOS provisioning."
  fi
fi

