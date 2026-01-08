#!/bin/bash
# Creates symlinks from home directory to dotfiles in ~/code/dotfiles

dir=~/code/dotfiles
files=".gitconfig .gitignore_global .zshrc"

cd "$dir" || exit 1

for file in $files; do
    if [[ -e ~/$file && ! -L ~/$file ]]; then
        echo "Backing up existing $file to ${file}.bak"
        mv ~/"$file" ~/"${file}.bak"
    fi

    if [[ ! -L ~/$file ]]; then
        echo "Creating symlink: ~/$file -> $dir/$file"
        ln -s "$dir/$file" ~/"$file"
    else
        echo "Symlink exists: ~/$file"
    fi
done

echo "Done!"
