#!/usr/bin/env zsh

################################################################################
# Variables
################################################################################

MODEL_NAME=$(system_profiler SPHardwareDataType | awk -F': ' '/Model Name/ {print $2}')

################################################################################
# System Settings
################################################################################

## General ---------------------------------------------------------------------

# Set computer name
sudo scutil --set ComputerName "P-Chan's $MODEL_NAME"

# Set system languages
defaults write NSGlobalDomain AppleLanguages -array "en" "ja"

# Appearance -------------------------------------------------------------------

# Enable dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Desktop & Dock ---------------------------------------------------------------

# Enable Dock auto hide
defaults write com.apple.dock autohide -bool true

# Set default browser to Arc
defaultbrowser browser

# Set Hot Corners (Top Right to Mission Control, Bottom Right to Desktop)
defaults write com.apple.dock wvous-tr-corner -int 2
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-corner -int 4
defaults write com.apple.dock wvous-bl-modifier -int 0

# Keyboard ---------------------------------------------------------------------

# Disable "Select the previous input source" shortcut (Ctrl + Space)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 "<dict><key>enabled</key><false/></dict>"

# Disable "Show Spotlight search" shortcut (Cmd + Space)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/></dict>"

################################################################################
# Finder
################################################################################

# Show folders first
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Set view style to column view
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Hide desktop icons
defaults write com.apple.finder CreateDesktop -bool false

# Set new window target to Home directory
defaults write com.apple.finder NewWindowTarget -string "PfHm"

# Show hidden files (e.g. dotfiles)
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Always expand save dialog
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true


################################################################################
# Others
################################################################################

# Arrange Dock
dockutil --remove all
[ -d "/Applications/Fantastical.app" ] && dockutil --add "/Applications/Fantastical.app"
[ -d "/Applications/Mimestream.app" ] && dockutil --add "/Applications/Mimestream.app"
[ -d "/Applications/Arc.app" ] && dockutil --add "/Applications/Arc.app"
[ -d "/Applications/Slack.app" ] && dockutil --add "/Applications/Slack.app"
[ -d "/Applications/Figma.app" ] && dockutil --add "/Applications/Figma.app"
[ -d "/Applications/1Password.app" ] && dockutil --add "/Applications/1Password.app"
[ -d "/Applications/Visual Studio Code.app" ] && dockutil --add "/Applications/Visual Studio Code.app"
[ -d "/Applications/Ghostty.app" ] && dockutil --add "/Applications/Ghostty.app"

# Unhide Library directory
chflags nohidden ~/Library

# Set local hostname
sudo scutil --set LocalHostName "p-chan-$(echo "$MODEL_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')"

echo "Please reboot"
