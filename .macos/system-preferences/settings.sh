#!/bin/bash

##
# 1-1. General
##

# Appearance
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# AirDrop & Handoff
defaults -currentHost write com.apple.controlcenter.plist AirplayRecieverEnabled -bool false

# TODO: Others

##
# 1-2. Desktop and Screen Saver
##

##
# 1-3. Dock
##

# Size
defaults write com.apple.dock tilesize -int 48

# Magnification
defaults write com.apple.dock magnification -bool false

# Position on screen
defaults write com.apple.dock orientation bottom

# Minimize windows using
defaults write com.apple.dock mineffect -string "genie"

# Prefer tabs when opening documents
# Command is not found

# Double-click a window's title bar to (no check -> "None", minimize -> "Minimize", zoom -> "Maximize")
defaults write NSGlobalDomain AppleActionOnDoubleClick -string "Maximize"

# Minimize windows into application icon
defaults write com.apple.dock minimize-to-application -bool false

# Animate opening applications
defaults write com.apple.dock launchanim -bool true

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Show indicators for open applications
defaults write com.apple.dock show-process-indicators -bool true

# Show recent application in Dock
defaults write com.apple.dock show-recents -bool false

##
# 1-4. Mission Control
##

# Automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# When switching to an application, switch to a Space with open windows for the application
defaults write NSGlobalDomain AppleSpacesSwitchOnActivate -bool true

# Group windows by application
defaults write com.apple.dock expose-group-by-app -bool false

# Displays have separate Spaces
defaults write com.apple.spaces spans-displays -bool true

# Hot Corners

# Top Left / -
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tl-modifier -int 0

# Top Right / Mission Control
defaults write com.apple.dock wvous-tr-corner -int 2
defaults write com.apple.dock wvous-tr-modifier -int 0

# Bottom Left / Desktop
defaults write com.apple.dock wvous-bl-corner -int 4
defaults write com.apple.dock wvous-bl-modifier -int 0

# Bottom Right / -
defaults write com.apple.dock wvous-br-corner -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

##
# 1-5. Siri
##

# Enable Ask Siri
defaults write com.apple.assistant.support "Assistant Enabled" -bool false

# Show Siri in menu bar
# Write Ex. Menu Bar

##
# 1-6. Spotlight
##

##
# 1-7. Language & Region
##

# Preferred languages
defaults write NSGlobalDomain AppleLanguages -array "en" "ja"

##
# 1-8. Notifications
##

##
# 2-1. Internet Accounts
##

##
# 2-2. Wallet & Apple Pay
##

##
# 2-3. Touch ID
##

##
# 2-4. User & Groups
##

##
# 2-5. Accessibility
##

##
# 2-6. Screen Time
##

##
# 2-7. Extensions
##

##
# 2-8. Security & Privacy
##

##
# 3-1. Software Update
##

##
# 3-2. Network
##

# Show Wi-Fi status in menu bar
# Write Ex. Menu Bar

# Show VPN status in menu bar
# Write Ex. Menu Bar

##
# 3-3. Bluetooth
##

# Show Bluetooth in menu bar
# Write Ex. Menu Bar

##
# 3-4. Sound
##

# Show volume in menu bar
# Write Ex. Menu Bar

##
# 3-5. Printers & Scanners
##

##
# 3-6. Keyboard
##

# Shortcut / Input Sources / Select the previous input source
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 60 "<dict><key>enabled</key><false/></dict>"

# Shortcut / Input Sources / Select next source in Input menu
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 61 "<dict><key>enabled</key><false/></dict>"

# Keyboard Shortcuts / Spotlight / Show Spotlight search
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/></dict>"

# Keyboard Shortcuts / Spotlight / Show Finder search window
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 "<dict><key>enabled</key><false/></dict>"

##
# 3-7. Trackpad
##

# Tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write -g com.apple.mouse.tapBehavior -bool true

# Silent clicking
defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 0

# Click
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 2

# Tracking Speed (0~3)
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1.5

# TODO: Others

##
# 3-8. Mouse
##

##
# 4-1. Displays
##

##
# 4-2. Sidecar
##

# Show Sidebar
defaults write com.apple.sidecar.display sidebarShown -bool false

# Show Touch Bar
defaults write com.apple.sidecar.display showTouchbar -bool false

# Enable double tap on Apple Pencil
defaults write com.apple.sidecar.display doubleTapEnabled -bool false

##
# 4-3. Energy Saver
##

# Show battery status in menu bar
# Write Ex. Menu Bar

# Advanced: Show Parcent
defaults write com.apple.controlcenter.plist BatteryShowPercentage -bool true

##
# 4-4. Data & Time
##

# Clock

# Show date and time in menu bar
# Write Ex. Menu Bar

# Format
defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d HH:mm:ss"

##
# 4-5. Sharing
##

##
# 4-6. Time Machine
##

# Back Up Automatically
# TODO: OFF

# Show Time Machine in menu bar
# Write Ex. Menu Bar

##
# 4-7. Startup Disk
##

##
# 4-8. Profiles
##

##
# Ex. Menu bar
##

defaults write com.apple.systemuiserver "NSStatusItem Visible Siri" -bool false
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.airport" -bool true
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.vpn" -bool true
defaults write com.apple.controlcenter.plist Bluetooth -int 18
defaults write com.apple.controlcenter.plist Sound -int 18
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.battery" -bool true
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.clock" -bool true
defaults write com.apple.systemuiserver "NSStatusItem Visible com.apple.menuextra.TimeMachine" -bool false

defaults write com.apple.systemuiserver menuExtras -array \
  "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
  "/System/Library/CoreServices/Menu Extras/Battery.menu" \
  "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
  "/System/Library/CoreServices/Menu Extras/Clock.menu" \
  "/System/Library/CoreServices/Menu Extras/Displays.menu" \
  "/System/Library/CoreServices/Menu Extras/Volume.menu" \
  "/System/Library/CoreServices/Menu Extras/VPN.menu"

##
# Ex. Others
##

# Control Center
defaults write com.apple.menuextra.clock.plist ShowSeconds -bool true

# Show ~/Library directory
chflags nohidden ~/Library

# Don't create .DS_Store on network stores
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# If ~/Screenshots directory does not exist, create it
if [ ! -d ~/Screenshots ]; then
  mkdir ~/Screenshots
fi

# Save screenshots to ~/Screenshots directory
defaults write com.apple.screencapture location ~/Screenshots/

##
# Ex. killall
##

killall Finder
killall -1 SystemUIServer

echo "Please reboot"
