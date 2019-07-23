
#curl -L conda.ml | bash


curl -O https://repo.anaconda.com/archive/Anaconda3-5.3.0-Linux-x86_64.sh
bash Anaconda3-5.3.0-Linux-x86_64.sh -b -p $HOME/anaconda
echo 'export PATH="$HOME/anaconda/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
#conda config --add channels conda-forge
echo "Installed Anaconda, and added to path, should be working now"
