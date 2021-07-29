#!/usr/bin/env bash
#
# script for setting up a new mac

# helper functions
function already_installed {
    echo "Already installed: $1"
}

# Ask for the administrator password upfront.
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished.
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &


# need this for cli tools
echo "Installing xcode"
xcode-select --install

# Check for Homebrew, and install if we don't have it
if test ! $(which brew); then
  echo "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update homebrew recipes
echo "Updating homebrew..."
brew update

# Install cli apps using brew
###############################################################################
echo "Updating cli apps using brew..."
apps=(
    bat
    git
    vim
    httpie
    fd
    fzf
    jq
    tree
    tldr
    htop
    neofetch
    # mac specific stuff
    mas
    # fnm is a node installer, see nvm also
    fnm
)

BREW_LIST=$(brew list)

for i in "${apps[@]}"
do
  echo $BREW_LIST | grep $i &>/dev/null
  if [[ $? != 0 ]] ; then
    brew install $i
  else
    already_installed $i
  fi
done

# Install apps using brew (brew calls them casks for some weird reason)
###############################################################################
echo "installing gui apps using brew case..."
apps=(
    # essential utils
    raycast
    karabiner-elements
    itsycal
    
    # web
    cyberduck
    transmission
    firefox
    google-chrome
    google-drive
    
    # writing apps
    obsidian
    nota
    notion
    
    # coding
    visual-studio-code
    ngrok
    iterm2
    tabby
    github
    # run this after: conda init "$(basename "${SHELL}")"
    #mambaforge
    
    # talk to ppl
    whatsapp
    microsoft-teams
    zoom
    
    # misc stuff
    kindle
    vlc
    spotify
    #steam
    balenaetcher
    
    # Quick Look Plugins (https://github.com/sindresorhus/quick-look-plugins)
    qlmarkdown
    qlcolorcode
    quicklook-csv
    qlstephen
)

BREW_LIST=$(brew list)

for i in "${apps[@]}"
do
  echo $BREW_LIST | grep $i &>/dev/null
  if [[ $? != 0 ]] ; then
    brew install --cask $i
  else
    already_installed $i
  fi
done

echo "Cleaning up brew"
brew cleanup

# dotfiles
###############################################################################
echo ""
echo "Copying dotfiles from Github"
cd ~
git clone https://github.com/khalido/dotfiles.git
cd dotfiles
sh makesymlinks.sh
cd ~

# Create a directory where code will live
mkdir -p ~/code


###############################################################################
# configure mac settings into sensible defaults
###############################################################################

# see https://macos-defaults.com/ for explanations and ideas

echo ""
echo "Setting some Mac settings..."

# General UI/UX
###############################################################################

# Require password as soon as screensaver or sleep mode starts
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

#"Allow text selection in Quick Look"
defaults write com.apple.finder QLEnableTextSelection -bool TRUE

#"Disabling OS X Gate Keeper"
#"(You'll be able to install any app you want from here on, not just Mac App Store apps)"
sudo spctl --master-disable
sudo defaults write /var/db/SystemPolicy-prefs.plist enabled -string no
defaults write com.apple.LaunchServices LSQuarantine -bool false

#"Disable smart quotes and smart dashes as they are annoying when typing code"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

#"Enabling full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

#"Enabling subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 2

#"Setting email addresses to copy as 'foo@example.com' instead of 'Foo Bar <foo@example.com>' in Mail.app"
defaults write com.apple.mail AddressesIncludeNameOnPasteboard -bool false

#"Preventing Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

#"Speeding up wake from sleep to 4 hours from an hour"
# http://www.cultofmac.com/221392/quick-hack-speeds-up-retina-macbooks-wake-from-sleep-os-x-tips/
sudo pmset -a standbydelay 14400

# Terminal
###############################################################################

#"Enabling UTF-8 ONLY in Terminal.app and setting the Pro theme by default"
defaults write com.apple.terminal StringEncodings -array 4
defaults write com.apple.Terminal "Default Window Settings" -string "Pro"
defaults write com.apple.Terminal "Startup Window Settings" -string "Pro"

# Trackpad, mouse, keyboard
###############################################################################

#"Setting trackpad & mouse speed to a reasonable number"
defaults write -g com.apple.trackpad.scaling 2
defaults write -g com.apple.mouse.scaling 2.5

# Enable tap to click (Trackpad) for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# enable three finger drag
defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerSwipeGesture -int 1
defaults write NSGlobalDomain com.apple.trackpad.threeFingerSwipeGesture -int 1

# Finder
###############################################################################

#"Expanding the save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

#"Setting screenshots location to ~/Desktop"
defaults write com.apple.screencapture location -string "$HOME/Desktop"

#"Setting screenshot format to PNG"
defaults write com.apple.screencapture type -string "png"

#"Showing icons for hard drives, servers, and removable media on the desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

#"Showing all filename extensions in Finder by default"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

#"Disabling the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

#"Use column view in all Finder windows by default"
defaults write com.apple.finder FXPreferredViewStyle Clmv

#"Avoiding the creation of .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

#"Enabling snap-to-grid for icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# Dock & Mission Control
###############################################################################

#"Setting the icon size of Dock items to 36 pixels for optimal size/screen-realestate"
defaults write com.apple.dock tilesize -int 36

#"Speeding up Mission Control animations and grouping windows by application"
defaults write com.apple.dock expose-animation-duration -float 0.1
defaults write com.apple.dock "expose-group-by-app" -bool true

#"Setting Dock to auto-hide and lowering the auto-hiding delay from 0.5"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0.2
defaults write com.apple.dock autohide-time-modifier -float 0.3

###############################################################################
# Transmission
###############################################################################

#"Use `~/Downloads/Incomplete` to store incomplete downloads"
defaults write org.m0k.transmission UseIncompleteDownloadFolder -bool true
defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Downloads/Incomplete"

#"Don't prompt for confirmation before downloading"
defaults write org.m0k.transmission DownloadAsk -bool false

#"Trash original torrent files"
defaults write org.m0k.transmission DeleteOriginalTorrent -bool true

#"Hide the donate message"
defaults write org.m0k.transmission WarningDonate -bool false

#"Hide the legal disclaimer"
defaults write org.m0k.transmission WarningLegal -bool false

killall Finder

echo "Setup almost finished!"

#Install Zsh & Oh My Zsh
echo "Installing Oh My ZSH..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
