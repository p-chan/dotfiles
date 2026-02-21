#!/usr/bin/env zsh

set -e

log_info () {
  echo "ℹ️ $1"
}

log_error () {
  echo "❌ $1"
}

log_success () {
  echo "✅ $1"
}

required_commands=("zsh" "vim" "git" "mise" "deno" "node" "claude" "xcode-select" "brew")

log_info "Checking required commands..."

missing_commands=()

for cmd in "${required_commands[@]}"; do
  if ! command -v "$cmd" &>/dev/null; then
    missing_commands+=("$cmd")
  fi
done

if [ ${#missing_commands[@]} -eq 0 ]; then
  log_success "All required commands are available."
else
  log_error "Some required commands are missing (${missing_commands[*]})"
  exit 1
fi
