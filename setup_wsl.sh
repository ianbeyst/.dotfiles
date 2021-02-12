#!/bin/sh

DFDIR=$(dirname $(readlink -f "$0"))
echo $DFDIR
. $DFDIR/config/profile


# Make directories if they don't exist yet
mkdir -p "$XDG_CONFIG_HOME"/vim
mkdir -p "$XDG_CONFIG_HOME"/vim/colors
mkdir -p "$XDG_DATA_HOME"/vim/undo
mkdir -p "$XDG_DATA_HOME"/vim/swap
mkdir -p "$XDG_DATA_HOME"/vim/backup
mkdir -p ~/data



# Create symlinks
ln -sfn $DFDIR/config/profile ~/.profile
ln -sfn $DFDIR/config/bashrc ~/.bashrc
ln -sfn $DFDIR/config/bash_profile ~/.bash_profile
ln -sfn $DFDIR/config/inputrc "$XDG_CONFIG_HOME"/inputrc
ln -sfn $DFDIR/config/xdg-dirs "$XDG_CONFIG_HOME"/user-dirs.dirs
ln -sfn $DFDIR/config/vimrc "$XDG_CONFIG_HOME"/vim/vimrc
ln -sfn $DFDIR/config/vimcolors "$XDG_CONFIG_HOME"/vim/colors/flattened_dark.vim
ln -sfn $DFDIR/data/bash_history ~/.local/share/bash_history



# Source .profile, .bash_profile and .bashrc and remove ~/.bash_history
. ~/.profile
rm ~/.bash_history



# Set up configuration with root access
sudo DFDIR=$DFDIR /bin/sh -c '
    # better lsl alias
    ln -sfn $DFDIR/scripts/lsl.sh /usr/local/bin/lsl
'
