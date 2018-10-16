#!/bin/bash

code_dir=~/code                    # all my code goes here

function yes_or_no {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}

# add stretch backports
if grep -qF "stretch-backports" /etc/apt/sources.list;then
echo "stretch-backports repo already there"
else
sudo bash -c 'echo "# Backports repository" >> /etc/apt/sources.list'
sudo bash -c 'echo "deb http://deb.debian.org/debian stretch-backports main contrib non-free" >> /etc/apt/sources.list'
echo "Added stretch-backports repo"
fi

# update packages
sudo apt-get update

# make the terminal nicer
sudo apt -t stretch-backports install fonts-powerline -y
sudo apt -t stretch-backports install tmux -y

#install tldr
loc=/usr/local/bin/tldr  # elevated privileges needed for some locations
sudo wget -qO $loc https://4e4.win/tldr
sudo chmod +x $loc

# make symlinks
echo "making symlinks to the config files listed in makesynlinks.sh"
./makesymlinks.sh

# make a code dir in the home dir
echo "Creating $code_dir in which to git clone all the repos"
mkdir -p $code_dir
echo "copying the clone script to $code_dir and running it"
cp gitcloneall.sh $code_dir
cd $code_dir
./gitcloneall.sh
echo "repos should have been all cloned to $code_dir"

# download anaconda
yes_or_no "Download Anaconda 5.3?" && \
curl -O https://repo.anaconda.com/archive/Anaconda3-5.3.0-Linux-x86_64.sh

# installing oh-my-bash
yes_or_no "Install oh my bash?" && \
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

echo "All done!"
