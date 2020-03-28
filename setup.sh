#!/bin/sh

DFDIR=$(dirname $(readlink -f "$0"))
. $DFDIR/secrets

# Make directories if they don't exist yet
mkdir -p "$XDG_CONFIG_HOME"/vim
mkdir -p "$XDG_CONFIG_HOME"/vim/colors
mkdir -p "$XDG_CONFIG_HOME"/git
mkdir -p "$XDG_DATA_HOME"/vim/undo
mkdir -p "$XDG_DATA_HOME"/vim/swap
mkdir -p "$XDG_DATA_HOME"/vim/backup
mkdir -p ~/data

# Create symlinks
ln -sfn $DFDIR/config/xinitrc ~/.xinitrc
ln -sfn $DFDIR/config/profile ~/.profile
ln -sfn $DFDIR/config/xdg-dirs "$XDG_CONFIG_HOME"/user-dirs.dirs
ln -sfn $DFDIR/config/ashrc "$XDG_CONFIG_HOME"/ashrc
ln -sfn $DFDIR/config/vimrc "$XDG_CONFIG_HOME"/vim/vimrc
ln -sfn $DFDIR/config/vimcolors "$XDG_CONFIG_HOME"/vim/colors/flattened_dark.vim
ln -sfn $DFDIR/config/redshift "$XDG_CONFIG_HOME"/redshift.conf

touch "$XDG_CONFIG_HOME"/git/config
git config --global user.name $GITNAME
git config --global user.email $GITEMAIL

sudo DFDIR=$DFDIR /bin/sh -c '
    # Suspend on critical battery state of charge
    mkdir -p /etc/periodic/1min
    cat /etc/crontabs/root | grep 1min || \
        echo "*       *       *       *       *       run-parts /etc/periodic/1min" \
        >> /etc/crontabs/root
    ln -sfn $DFDIR/scripts/autosuspend.sh /etc/periodic/1min/autosuspend

    # Suspend and lock on lid close
    mkdir -p /etc/acpi/LID
    ln -sfn $DFDIR/scripts/lidclose.sh /etc/acpi/LID/00000080

    # Xorg settings
    mkdir -p /etc/X11/xorg.conf.d
    ln -sfn $DFDIR/config/xorg_touchpad /etc/X11/xorg.conf.d/30-touchpad.conf
    ln -sfn $DFDIR/config/xorg_security /etc/X11/xorg.conf.d/00-security.conf

    # Backlight brightess
    ln -sfn $DFDIR/scripts/bbright.sh /usr/local/bin/bbright
'
