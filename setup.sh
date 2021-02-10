#!/bin/sh

DFDIR=$(dirname $(readlink -f "$0"))
. $DFDIR/secrets
. $DFDIR/config/profile


# Make directories if they don't exist yet
mkdir -p "$XDG_CONFIG_HOME"/vim
mkdir -p "$XDG_CONFIG_HOME"/npm
mkdir -p "$XDG_CONFIG_HOME"/vim/colors
mkdir -p "$XDG_CONFIG_HOME"/git
mkdir -p "$XDG_DATA_HOME"/vim/undo
mkdir -p "$XDG_DATA_HOME"/vim/swap
mkdir -p "$XDG_DATA_HOME"/vim/backup
mkdir -p ~/data
mkdir -p ~/src
mkdir -p ~/data/webcam



# Create symlinks
ln -sfn $DFDIR/config/xinitrc ~/.xinitrc
ln -sfn $DFDIR/config/profile ~/.profile
ln -sfn $DFDIR/config/bashrc ~/.bashrc
ln -sfn $DFDIR/config/bash_profile ~/.bash_profile
ln -sfn $DFDIR/config/Xmodmap "$XDG_CONFIG_HOME"/Xmodmap
ln -sfn $DFDIR/config/inputrc "$XDG_CONFIG_HOME"/inputrc
ln -sfn $DFDIR/config/xdg-dirs "$XDG_CONFIG_HOME"/user-dirs.dirs
ln -sfn $DFDIR/config/vimrc "$XDG_CONFIG_HOME"/vim/vimrc
ln -sfn $DFDIR/config/vimcolors "$XDG_CONFIG_HOME"/vim/colors/flattened_dark.vim
ln -sfn $DFDIR/config/npmrc "$XDG_CONFIG_HOME"/npm/npmrc
ln -sfn $DFDIR/config/redshift "$XDG_CONFIG_HOME"/redshift.conf
ln -sfn $DFDIR/data/password-store ~/.local/share/password-store
ln -sfn $DFDIR/data/bash_history ~/.local/share/bash_history
ln -sfn $DFDIR/data/gnupg ~/.local/share/gnupg
ln -sfn $DFDIR/data/aws ~/.local/share/aws
ln -sfn $DFDIR/data/ssh ~/.ssh
ln -sfn $DFDIR/data/mozilla ~/.mozilla
ln -sfn $DFDIR/scripts/backup.sh ~/.local/bin/backup
ln -sfn $DFDIR/scripts/sandboxed_firefox/sandboxed_firefox.sh ~/.local/bin/firefox



# Source .profile, .bash_profile and .bashrc and remove ~/.bash_history
. ~/.profile
. ~/.bash_profile
. ~/.bashrc
rm ~/.bash_history



# Set up git
touch "$XDG_CONFIG_HOME"/git/config
git config --global user.name $GITNAME
git config --global user.email $GITEMAIL



# Build dwm, st and slstatus
cd ~/src
git clone https://git.suckless.org/dwm
git clone https://git.suckless.org/st
git clone https://github.com/ianbeyst/slstatus.git

cd dwm
git checkout cb3f58ad06993f7ef3a7d8f61468012e2b786cab
patch -p1 < "$DFDIR"/patches/dwm-customized-af20849.diff
make
sudo make install
make clean

cd ../st
git checkout a2c479c
patch -p1 < "$DFDIR"/patches/st-customized-a2c479c.diff
make
sudo make install
make clean

cd ../slstatus
for dev in `ls /sys/class/net`; do
    if [ -d "/sys/class/net/$dev/wireless" ]; then WIFIDEV=$(echo $dev); fi;
done
sed -i 's/wlp1s0/'$WIFIDEV'/g' config.h
make
sudo make install
make clean
cd ..
rm -rf dwm
rm -rf st
rm -rf slstatus



# Set up configuration with root access
sudo DFDIR=$DFDIR /bin/sh -c '
    # Make bash history file append only
    chattr +a $DFDIR/data/bash_history

    # better lsl alias
    ln -sfn $DFDIR/scriptslsl.sh /usr/local/bin/lsl

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

    # Automatic webcam capture
    ln -sfn $DFDIR/scripts/webcamshot.sh /usr/local/bin/webcamshot
    echo "* * * * * webcamshot" > /etc/crontabs/io

    # Map caps lock to escape in terminals
    ln -sfn $DFDIR/scripts/mapcapslock.sh /etc/local.d/mapcapslock.start
    rc-update add local default
'
