#!/usr/bin/env bash
# ~/.config/dotfiles/macos.sh
# macOS system preferences — Shane's actual settings
#
# Captured from: MacBook Pro, macOS Sequoia 15.x (Darwin 25.3.0)
# Last updated:  2026-03-20
#
# Usage:
#   bash ~/.config/dotfiles/macos.sh
#
# This script writes to macOS preference domains using `defaults write`.
# Most changes take effect after restarting the affected app. Some (keyboard,
# trackpad, scrolling) require a full logout or restart.
#
# The script is idempotent — safe to run multiple times.
#
# Called automatically by bootstrap.sh (step 10), or run standalone.

set -euo pipefail

echo "Applying macOS defaults..."

# Close System Settings to prevent it from overriding changes we make
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

# ============================================================================
# General UI/UX
# ============================================================================

# Dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

# Always show scrollbars (options: WhenScrolling, Automatic, Always)
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Expand save panel by default (show full directory browser)
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Save to disk (not iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Show all file extensions in Finder and Open/Save dialogs
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable natural scrolling (trackpad scroll matches finger direction)
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Sidebar icon size: medium (1=small, 2=medium, 3=large)
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

# ============================================================================
# Keyboard
# ============================================================================
# These are critical for a good nvim experience. The default macOS key repeat
# is painfully slow. These values give fast, responsive repeat.

# Key repeat rate: 2 = ~30ms between repeats (fastest practical setting)
# For reference: 1 = ~15ms (can cause issues), 6 = default
defaults write NSGlobalDomain KeyRepeat -int 2

# Delay until key repeat starts: 15 = 225ms
# For reference: 25 = default (375ms), 10 = very short
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold for accent characters — enables key repeat in all apps
# Without this, holding a key in some apps shows an accent picker instead of repeating
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Disable all auto-correction features (these interfere with code editing)
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# ============================================================================
# Trackpad
# ============================================================================

# Tap to click (instead of requiring a physical press)
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# Two-finger click for right-click
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true

# Pinch to zoom
defaults write com.apple.AppleMultitouchTrackpad TrackpadPinch -bool true

# Rotate gesture
defaults write com.apple.AppleMultitouchTrackpad TrackpadRotate -bool true

# Momentum scrolling (content keeps moving after lifting fingers)
defaults write com.apple.AppleMultitouchTrackpad TrackpadMomentumScroll -bool true

# Light click threshold — 0 is the lightest tap sensitivity
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 0

# ============================================================================
# Dock
# ============================================================================

# Auto-hide the Dock
defaults write com.apple.dock autohide -bool true

# Remove auto-hide delay (Dock appears instantly on hover)
defaults write com.apple.dock autohide-delay -float 0

# Remove auto-hide animation (Dock appears/disappears instantly)
defaults write com.apple.dock autohide-time-modifier -float 0

# Icon size: 45 pixels
defaults write com.apple.dock tilesize -int 45

# Show only running apps in the Dock (no persistent pinned apps)
defaults write com.apple.dock static-only -bool true

# Don't show recent applications in the Dock
defaults write com.apple.dock show-recents -bool false

# Make hidden app icons translucent
defaults write com.apple.dock showhidden -bool true

# Minimize windows into their application icon (saves Dock space)
defaults write com.apple.dock minimize-to-application -bool true

# Group windows by application in Mission Control / Exposé
defaults write com.apple.dock expose-group-apps -bool true

# Remove Springboard (Launchpad) animations
defaults write com.apple.dock springboard-hide-duration -float 0
defaults write com.apple.dock springboard-show-duration -float 0
defaults write com.apple.dock springboard-page-duration -float 0

# Hot corners — trigger actions by moving the cursor to screen corners
# Values: 0=disabled, 1=disabled, 2=Mission Control, 3=Application Windows,
#         4=Desktop, 5=Start Screen Saver, 6=Disable Screen Saver,
#         7=Dashboard, 10=Put Display to Sleep, 11=Launchpad, 12=Notification Center
# Modifier: 0=none, 1048576=cmd (require holding cmd to trigger)
defaults write com.apple.dock wvous-tl-corner -int 3       # Top left → Application Windows
defaults write com.apple.dock wvous-tl-modifier -int 1048576
defaults write com.apple.dock wvous-tr-corner -int 1       # Top right → disabled
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-corner -int 2       # Bottom left → Mission Control
defaults write com.apple.dock wvous-bl-modifier -int 1048576
defaults write com.apple.dock wvous-br-corner -int 4       # Bottom right → Desktop
defaults write com.apple.dock wvous-br-modifier -int 1048576

# ============================================================================
# Mission Control
# ============================================================================

# Don't automatically rearrange Spaces based on most recent use
# (keeps Spaces in the order you set them — important for muscle memory)
defaults write com.apple.dock mru-spaces -bool false

# ============================================================================
# Finder
# ============================================================================

# Show hidden files (dotfiles)
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show path bar at the bottom of Finder windows
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar at the bottom (item count, disk space)
defaults write com.apple.finder ShowStatusBar -bool true

# Default to column view (options: icnv=icon, clmv=column, Nlsv=list, glyv=gallery)
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Don't warn when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Search the current folder by default (not "This Mac")
# Options: SCcf=current folder, SCev=this Mac, SCsp=previous scope
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# New Finder windows open to: Computer/Volumes view
# Options: PfHm=Home, PfDe=Desktop, PfDo=Documents, PfVo=Computer
defaults write com.apple.finder NewWindowTarget -string "PfVo"

# Disable Finder animations
defaults write com.apple.finder AnimateInfoPanes -bool false
defaults write com.apple.finder AnimateWindowZoom -bool false

# ============================================================================
# Screenshots
# ============================================================================

# Save screenshots as PNG (options: png, jpg, gif, pdf, bmp, tiff)
defaults write com.apple.screencapture type -string "png"

# Disable drop shadow on window screenshots (cleaner for sharing)
defaults write com.apple.screencapture disable-shadow -bool true

# ============================================================================
# Safari
# ============================================================================

# Enable the Develop menu (Web Inspector, JS console, etc.)
defaults write com.apple.Safari IncludeDevelopMenu -bool true

# Send "Do Not Track" HTTP header
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

# Show the full URL in the address bar (not just the domain)
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# ============================================================================
# Apply changes
# ============================================================================

echo "Restarting affected applications..."

for app in "Dock" "Finder" "SystemUIServer"; do
    killall "${app}" 2>/dev/null || true
done

echo ""
echo "Done. Most settings are now active."
echo ""
echo "Some changes require a logout or restart to take effect:"
echo "  - Keyboard repeat rate and delay"
echo "  - Trackpad tap to click"
echo "  - Scroll direction"
echo ""
echo "Restart recommended."
