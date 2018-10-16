code_dir=~/code                    # all my code goes here

# update packages
sudo apt-get update

# installing oh-my-bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

# make symlinks
./makesymlinks.sh

# make a code dir in the home dir
echo "Creating $code_dir in which to git clone all the repos"
mkdir -p $code_dir
echo "copying the clone script to $code_dir and running it"
cp gitcloneall.sh $code_dir
cd $code_dir
./ gitcloneall.sh
echo "repos should have been all cloned to $code_dir"
