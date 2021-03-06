#!/bin/bash

set -e
old_dir=$HOME/.dotfiles_old

if [ ! -f $PWD/README ]; then
	echo "I couldn't find README. Did you run install.sh from the dotfiles
	directory?"
	exit 1
fi

if [ -d "$old_dir" ]; then
	echo "ERROR: $old_dir already exists! I refuse to clobber the old backups."
	exit 1
fi

# Adds a leading . if it's necessary
function trans_name() {
if [ $(dirname $1) = "" ] || [ $(dirname $1) = "." ]; then
    echo ./.$(basename $1)
else
    echo $1
fi
}

# Backs up files we're about to clobber.
find . -type f ! -path '*.git/*' -print0 | while IFS= read -r -d $'\0' path; do
if [ -f "$HOME/$(trans_name $path)" ]; then
    mkdir -p "$old_dir/$(dirname $path)"
    cp "$HOME/$(trans_name $path)" "$old_dir/$path"
fi
done

# Create directory structure corresponding to this one.
find . -type d ! -path '*.git/*' -exec mkdir -p "$HOME/{}" \;

# Create links to files here, changing the name to add a leading . if the file
# isn't in a directory.
find . -type f ! -path '*.git/*' -print0 | while IFS= read -r -d $'\0' path; do
ln -sf "$PWD/$path" "$HOME/$(trans_name $path)"
done

# If vim and git are available, clone the Vundle repo to the requiste place.
if [ -d "$HOME/.vim/bundle/Vundle.vim" ]; then
    true
else
    wgit=`which git`
    wvim=`which vim`

    if [ -z $wvim ]; then
        echo "Vim not found in PATH; not boostrapping vundle"
    fi

    if [ -z $wgit ]; then
        echo "Git not found in PATH; not bootstrapping vundle"
    fi

    mkdir -p $HOME/.vim/bundle/Vundle.vim
    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
