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

# add stretch backports since crostini comes with stretch which has hella old packages
echo "#####################################################################"
echo "Adding stetch-backports repo"
if grep -qF "stretch-backports" /etc/apt/sources.list;then
  echo "stretch-backports repo already there"
else
  sudo bash -c 'echo "# Backports repository" >> /etc/apt/sources.list'
  sudo bash -c 'echo "deb http://deb.debian.org/debian stretch-backports main contrib non-free" >> /etc/apt/sources.list'
  echo "Added stretch-backports repo"
fi

# update packages
sudo apt update && sudo apt upgrade

echo "#####################################################################"
echo "Installing apps"
sudo apt -t stretch-backports install fonts-powerline tmux wget jq software-properties-common curl -y

curl -L "https://go.microsoft.com/fwlink/?LinkID=760868" > vscode.deb
sudo apt install ./vscode.deb -y
echo "Installed VS Code"
rm vscode.deb

# make symlinks
echo "making symlinks to the config files listed in makesymlinks.sh"
./makesymlinks.sh


# download and install anaconda, nodejs10 and plotly
if ask "Do you want to download & install Anaconda & nodejs10?"; then
  curl -O https://repo.anaconda.com/archive/Anaconda3-2018.12-Linux-x86_64.sh
  bash Anaconda3-2018.12-Linux-x86_64.sh -b -p $HOME/anaconda
  echo 'export PATH="$HOME/anaconda/bin:$PATH"' >> ~/.bashrc
  source ~/.bashrc
  #conda config --add channels conda-forge
  echo "Installed Anaconda, and added to path, should be working now"
  
  #echo "Installing tldr and misc utils" # do this when needed
  #pip install tldr
  # conda install visidata
  
  # install nodejs cause plotly
  curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
  sudo apt install -y nodejs

  # I use plotly all the time, so installing it
  #conda install -c plotly plotly
  #export NODE_OPTIONS=--max-old-space-size=4096
  #jupyter labextension install @jupyter-widgets/jupyterlab-manager --no-build
  #jupyter labextension install plotlywidget --no-build
  #jupyter labextension install @jupyterlab/plotly-extension --no-build
  #jupyter lab build
  #unset NODE_OPTIONS
fi

echo "#####################################################################"

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


# installing oh-my-bash
ask "Install oh my bash?" && \
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

# check if it makes it here after the oh-my-bash command
echo "All done!"
