#!/bin/bash

# Don't show items on Desktop
defaults write com.apple.finder CreateDesktop -bool false

# Open a new Finder window in home directory
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# Show all files
defaults write com.apple.finder AppleShowAllFiles YES

# Show Path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show Status Bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show Tab View
defaults write com.apple.finder ShowTabView -bool true

# Show all extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Open save panel with expanded
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true


# Kill all
killall Finder
killall -1 SystemUIServer

echo "Please reboot"
