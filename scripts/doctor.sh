#!/usr/bin/env zsh

set -e

is_darwin() {
  [[ "$(uname)" == "Darwin" ]]
}

log_info () {
  echo "ℹ️ $1"
}

log_error () {
  echo "❌ $1"
}

log_success () {
  echo "✅ $1"
}


required_commands=("zsh" "vim" "git" "mise" "deno" "go" "node" "rustc")
darwin_required_commands=("xcode-select" "brew")

log_info "Checking required commands..."

missing_commands=()

if is_darwin; then
  required_commands+=("${darwin_required_commands[@]}")
fi

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
