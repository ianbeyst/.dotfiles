#!/bin/sh

# Make directories if they don't exist yet
mkdir -p "$XDG_CONFIG_HOME"/vim
mkdir -p "$XDG_CONFIG_HOME"/vim/colors
mkdir -p "$XDG_DATA_HOME"/vim/undo
mkdir -p "$XDG_DATA_HOME"/vim/swap
mkdir -p "$XDG_DATA_HOME"/vim/backup
mkdir -p ~/data

# Create symlinks
ln -sfn ~/.dotfiles/xinitrc ~/.xinitrc
ln -sfn ~/.dotfiles/profile ~/.profile
ln -sfn ~/.dotfiles/user-dirs.dirs "$XDG_CONFIG_HOME"/user-dirs.dirs
ln -sfn ~/.dotfiles/ashrc "$XDG_CONFIG_HOME"/ashrc
ln -sfn ~/.dotfiles/vimrc "$XDG_CONFIG_HOME"/vim/vimrc
ln -sfn ~/.dotfiles/vimcolors "$XDG_CONFIG_HOME"/vim/colors/flattened_dark.vim
ln -sfn ~/.dotfiles/redshift "$XDG_CONFIG_HOME"/redshift.conf
