#!/bin/bash

set -e

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


if [ -z "$DOTFILES_DIR" ]; then
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

    brew bundle --file="$DOTFILES_DIR/Brewfile"

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

  mise install

  eval "$(mise env -s bash)"

  log_success "Successfully installed mise tools."
else
  log_warn "mise command not found. Skipping mise tool installation."
fi

if [ "$CI" != "true" ] && ! is_codespaces; then
  if type deno &>/dev/null; then
    has_code=false
    has_code_insiders=false

    if type code &>/dev/null; then
      has_code=true
    fi

    if type code-insiders &>/dev/null; then
      has_code_insiders=true
    fi

    if [ "$has_code" = true ] || [ "$has_code_insiders" = true ]; then
      if [ "$has_code" = true ] && [ "$has_code_insiders" = true ]; then
        log_info "Installing VSCode extensions for both VSCode and VSCode Insiders..."

        DOTFILES_DIR=$DOTFILES_DIR deno run -A "$DOTFILES_DIR/scripts/code-extensions.ts" import
        DOTFILES_DIR=$DOTFILES_DIR deno run -A "$DOTFILES_DIR/scripts/code-extensions.ts" import --insiders

        log_success "Successfully installed VSCode extensions for both VSCode and VSCode Insiders."
      elif [ "$has_code" = true ]; then
        log_info "Installing VSCode extensions for VSCode..."

        DOTFILES_DIR=$DOTFILES_DIR deno run -A "$DOTFILES_DIR/scripts/code-extensions.ts" import

        log_success "Successfully installed VSCode extensions for VSCode."
      elif [ "$has_code_insiders" = true ]; then
        log_info "Installing VSCode extensions for VSCode Insiders..."

        DOTFILES_DIR=$DOTFILES_DIR deno run -A "$DOTFILES_DIR/scripts/code-extensions.ts" import --insiders

        log_success "Successfully installed VSCode extensions for VSCode Insiders."
      fi
    else
      log_warn "code or code-insiders command not found. Skipping VSCode extensions import."
    fi
  else
    log_warn "deno command not found. Skipping VSCode extensions import."
  fi
else
  log_info "CI environment detected. Skipping VSCode extensions import."
fi


if is_darwin; then
  if [ "$CI" != "true" ]; then
    log_info "Provisioning macOS..."

    bash "$DOTFILES_DIR/scripts/provisioning.sh"

    log_success "Successfully provisioned macOS."
  else
    log_info "CI environment detected. Skipping macOS provisioning."
  fi
fi

