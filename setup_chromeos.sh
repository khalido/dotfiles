#!/bin/bash

code_dir=~/code                    # all my code goes here

# function to ask user yes/no
function ask {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}

echo "\nCloning dotfiles from Github"
echo "##############################################################"
cd ~
git clone https://github.com/khalido/dotfiles.git
cd dotfiles
sh makesymlinks.sh
cd ~

# Create a directory where code will live
mkdir -p ~/code

# list version
echo "\nDebian Version"
echo "##############################################################"
cat /etc/os-release

echo "\nInstalling apt stuff"
echo "##############################################################"

# add testing repo else packages too old
# not using as it updates way too many things so left for future use
# if grep -qF "testing" /etc/apt/sources.list;then
#   echo "testing repo already there"
# else
#   sudo bash -c 'echo "# test repository" >> /etc/apt/sources.list'
#   sudo bash -c 'echo "deb http://http.us.debian.org/debian/ testing non-free contrib main" >> /etc/apt/sources.list'
# fi

# update packages
echo "Updating packages using apt"
sudo apt update && sudo apt upgrade -y
# consider build-essential if needed
sudo apt install gnome-keyring fonts-powerline software-properties-common -y


echo "\nInstall latest .deb versions of cli apps"
echo "##############################################################"

# grab latest amd64 deb url
URL=$(curl -L -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep -o -E "https://(.*)bat-musl_(.*)_amd64.deb")
curl -L $URL > bat.deb
sudo apt install ./bat.deb -y
rm bat.deb

echo "\nInstall gui apps"
echo "##############################################################"

echo "Installing vs code"
curl -L "https://go.microsoft.com/fwlink/?LinkID=760868" > vscode.deb
sudo apt install ./vscode.deb -y
rm vscode.deb

echo "Insalling Obsidian"
# grab latest amd64 deb url
URL=$(curl -L -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep -o -E "https://(.*)obsidian_(.*)_amd64.deb")
curl -L $URL > obsidian.deb
sudo apt install ./obsidian.deb -y
rm obsidian.deb


# make symlinks
echo "making symlinks to the config files listed in makesymlinks.sh"
./makesymlinks.sh


echo "\nInstalling dev stuff: node, mambaforge"
echo "##############################################################"

# echo "Installing pipx for global python tools"
# python3 -m pip install --user pipx
# python3 -m pipx ensurepath

echo "Installing Mambaforge for conda envs in vscode"
curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh
bash Mambaforge-$(uname)-$(uname -m).sh

# install volta and node
echo "Installing Volta"
#curl -fsSL https://fnm.vercel.app/install | bash
#fnm install 16.x

echo "Installing volta and latest node"
curl https://get.volta.sh | bash
volta install node

echo "Installing global cli tools using npm"
npm install -g tldr

echo "\nOptional stuff left for the end"
echo "##############################################################"

# install brew, cause why not
if ask "install homebrew?"; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ask "Do you want to download all repos into ~/code?"; then
  echo "downloading all my public git repos"
  # make a code dir in the home dir
  echo "Creating $code_dir in which to git clone all the repos"
  mkdir -p $code_dir
  echo "copying the clone script to $code_dir and running it"
  cp gitcloneall.sh $code_dir
  cd $code_dir
  ./gitcloneall.sh
  echo "repos should have been all cloned to $code_dir if yes"
fi


# check if it makes it here after
echo "\nAll Done!"
