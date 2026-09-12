#!/bin/sh

PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
export PATH

exec mise exec -- node "$HOME/.config/herdr/services/terminal-title-label/daemon.mjs"
