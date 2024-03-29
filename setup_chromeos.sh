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

function header {
        echo -e "\n"
        for i in "$*"; do echo "$i"; done;
        echo "#########################################"
}

header "Cloning dotfiles from Github"
cd ~
git clone https://github.com/khalido/dotfiles.git
echo "making symlinks to the config files listed in makesymlinks.sh"
cd dotfiles
sh makesymlinks.sh
cd ~

# list version
header "Debian Version"
cat /etc/os-release

header "Installing apt stuff"

# update packages
echo "Updating packages using apt"
sudo apt update --allow-releaseinfo-change && sudo apt upgrade -y

# install essentials
sudo apt install gnome-keyring fonts-powerline software-properties-common build-essential -y

# add backports to sources.list else packages too old
# if grep -qF "-backports" /etc/apt/sources.list;then
#   echo "backports repo already there"
# else
#   sudo bash -c 'echo "# backports repository" >> /etc/apt/sources.list'
#   sudo bash -c 'echo "deb http://deb.debian.org/debian bullseye-backports main contrib non-free" >> /etc/apt/sources.list'
# fi

header "Install latest .deb versions of cli apps"

# grab latest amd64 deb url for bat
URL=$(curl -L -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep -o -E "https://(.*)bat-musl_(.*)_amd64.deb")
curl -L $URL > bat.deb
sudo apt install ./bat.deb -y
rm bat.deb

header "Install gui apps"

echo "Installing vs code"
curl -L "https://go.microsoft.com/fwlink/?LinkID=760868" > vscode.deb
sudo apt install ./vscode.deb -y
rm vscode.deb

echo "Insalling Obsidian"
# grab latest amd64 deb url
URL=$(curl -L -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases | grep -o -E "https://(.*)obsidian_(.*)_amd64.deb")
curl -L $URL > obsidian.deb
sudo apt install ./obsidian.deb -y
rm obsidian.deb

header "Installing dev stuff: node, mambaforge"

# echo "Installing pipx for global python tools"
# python3 -m pip install --user pipx
# python3 -m pipx ensurepath

echo "Installing Mambaforge for conda envs in vscode"
curl -L -O https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh
bash Mambaforge-$(uname)-$(uname -m).sh -b
# add conda mamba to bash shell
# only works for bash shell, change when chromeos switches to zsh
eval "$(~/mambaforge/bin/conda shell.bash hook)"
conda init

mamba create -n py39 python=3.9 matplotlib pandas seaborn jupyterlab black isort mako markdown pyyaml pymdown-extensions jupyterlab_code_formatter -y
mamba create -n streamlit python=3.9 streamlit matplotlib pandas numpy black isort -y

# install volta and node
echo "Installing Volta.sh and Node 17"
curl https://get.volta.sh | bash
source ~/.bashrc
volta install node@17

echo "Installing global cli tools using npm"
npm install -g tldr
npm i -g vercel

header "Optional stuff left for the end"

if ask "Do you want to download all repos into ~/code?"; then
  echo "downloading all my public git repos"
  # make a code dir in the home dir
  echo "Creating $code_dir in which to git clone all the repos"
  mkdir -p $code_dir
  echo "copying the clone script to $code_dir and running it"
  cp ~/dotfiles/gitcloneall.sh $code_dir
  cd $code_dir
  ./gitcloneall.sh
  echo "repos should have been all cloned to $code_dir if yes"
fi

# install brew, cause why not
if ask "install homebrew?"; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# check if it makes it here after all the above
header "All Done!"
