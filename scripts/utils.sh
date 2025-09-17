#!/bin/bash

export is_darwin=0

if [[ "$(uname)" == "Darwin" ]]; then
  is_darwin=1
fi

log_info() {
  echo "ℹ️ $1"
}

log_warn() {
  echo "⚠️ $1"
}

log_success() {
  echo "✅ $1"
}
