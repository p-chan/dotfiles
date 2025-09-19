#!/bin/bash

is_darwin() {
  [[ "$(uname)" == "Darwin" ]]
}

is_linux() {
  [[ "$(uname)" == "Linux" ]]
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
