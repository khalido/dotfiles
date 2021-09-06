# this is old, probably not worth using anymore

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

# update packages
sudo apt update && sudo apt upgrade

echo "#####################################################################"
echo "Installing apps"
#sudo apt install fonts-powerline software-properties-common curl -y

curl -L "https://go.microsoft.com/fwlink/?LinkID=760868" > vscode.deb
sudo apt install ./vscode.deb -y
echo "Installed VS Code"
rm vscode.deb

# make symlinks
echo "making symlinks to the config files listed in makesymlinks.sh"
./makesymlinks.sh


# install brew, cause why not
if ask "install homebrew?"; then
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# download and install anaconda, nodejs10 and plotly
if ask "Do you want to download & install Miniconda?"; then
  curl -O <https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh>
  sh Miniconda3-latest-Linux-x86_64.sh
  echo "Installed Anaconda, and added to path, should be working now"
  
  #echo "Installing tldr and misc utils" # do this when needed
  #pip install tldr
  # conda install visidata
  
  # install nvm to later install node
  #curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
  # or install node directly directly
  #curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
  #sudo apt install -y nodejs

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
