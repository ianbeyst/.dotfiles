#!/bin/sh -e
PROGNAME="$0"
SRCDIR=$(dirname $(readlink -f "$0"))
DFDIR="$SRCDIR/.."


usage() {
    cat << EOF >&2
Usage: $PROGNAME [-h] [-d <devicename>]

-h:          Show this help.
-d <device>: Specify the name of the device (docker | librem)

EOF
    exit 1
}



while getopts hd: o; do
    case "$o" in
        (h) usage;;
        (d) DEVICE_NAME="$OPTARG";;
        (*) usage
    esac
done
shift "$((OPTIND-1))"



if [ "$DEVICE_NAME" = "librem" ]; then
    GUI="true"
fi



. "$DFDIR/config/profile"



# Make sure all files and directories exist
mkdir -p "$XDG_CONFIG_HOME/vim"
mkdir -p "$XDG_CONFIG_HOME/npm"
mkdir -p "$XDG_CONFIG_HOME/vim/colors"
mkdir -p "$XDG_DATA_HOME/vim/undo"
mkdir -p "$XDG_DATA_HOME/vim/swap"
mkdir -p "$XDG_DATA_HOME/vim/backup"
mkdir -p "$HOME/data"
mkdir -p "$HOME/src"
mkdir -p "$HOME/.local/bin"
mkdir -p "$DFDIR/data"

if [ "$DEVICE_NAME" = "librem" ]; then
    mkdir -p "$HOME/data/webcam"
fi



# Create symlinks
ln -sfn "$DFDIR/config/profile" "$HOME/.profile"
ln -sfn "$DFDIR/config/bashrc" "$HOME/.bashrc"
ln -sfn "$DFDIR/config/bash_profile" "$HOME/.bash_profile"
ln -sfn "$DFDIR/data/bash_history" "$XDG_CONFIG_HOME/bash_history"
ln -sfn "$DFDIR/config/inputrc" "$XDG_CONFIG_HOME/inputrc"
ln -sfn "$DFDIR/config/xdg-dirs" "$XDG_CONFIG_HOME/user-dirs.dirs"
ln -sfn "$DFDIR/config/vimrc" "$XDG_CONFIG_HOME/vim/vimrc"
ln -sfn "$DFDIR/config/vimcolors" "$XDG_CONFIG_HOME/vim/colors/flattened_dark.vim"
ln -sfn "$DFDIR/config/npmrc" "$XDG_CONFIG_HOME/npm/npmrc"
ln -sfn "$DFDIR/scripts/backup.sh" "$HOME/.local/bin/backup"
ln -sfn "$DFDIR/scripts/lsl.sh" "$HOME/.local/bin/lsl"

if [ "$GUI" = "true" ]; then
    ln -sfn $DFDIR/config/xinitrc ~/.xinitrc
    ln -sfn $DFDIR/config/Xmodmap "$XDG_CONFIG_HOME"/Xmodmap
    ln -sfn $DFDIR/config/redshift "$XDG_CONFIG_HOME"/redshift.conf
    ln -sfn $DFDIR/scripts/sandboxed_firefox/sandboxed_firefox.sh ~/.local/bin/firefox
    ln -sfn $DFDIR/scripts/sandboxed_slack/sandboxed_slack.sh ~/.local/bin/slack
    ln -sfn $DFDIR/scripts/sandboxed_chrome/sandboxed_chrome.sh ~/.local/bin/chrome
    ln -sfn $DFDIR/scripts/sandboxed_spotify/sandboxed_spotify.sh ~/.local/bin/spotify

    mkdir -p "$DFDIR/data/spotify"
    ln -sfn "$DFDIR/data/spotify" "$XDG_CONFIG_HOME/spotify"

    mkdir -p "$DFDIR/data/mozilla"
    ln -sfn "$DFDIR/data/mozilla" "$HOME/.mozilla"

    mkdir -p "$DFDIR/data/google-chrome"
    ln -sfn "$DFDIR/data/google-chrome" "$XDG_CONFIG_HOME/google-chrome"

    mkdir -p "$DFDIR/data/Slack"
    ln -sfn "$DFDIR/data/Slack" "$XDG_CONFIG_HOME/Slack"
fi

if [ "$DEVICE_NAME" = "librem" ]; then
    ln -sfn "$DFDIR/scripts/bbright.sh" "$HOME/.local/bin/bbright"
fi

mkdir -p "$DFDIR/data/gnupg"
ln -sfn "$DFDIR/data/gnupg" "$XDG_CONFIG_HOME/gnupg"

mkdir -p "$DFDIR/data/aws"
ln -sfn "$DFDIR/data/aws" "$XDG_CONFIG_HOME/aws"

mkdir -p "$DFDIR/data/ssh"
ln -sfn "$DFDIR/data/ssh" "$HOME/.ssh"

mkdir -p "$DFDIR/data/password-store"
ln -sfn "$DFDIR/data/password-store" "$XDG_CONFIG_HOME/password-store"



# Install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git /tmp/fzf
cp /tmp/fzf/shell/completion.bash "$XDG_CONFIG_HOME/fzf_completion.bash"
cp /tmp/fzf/shell/key-bindings.bash "$XDG_CONFIG_HOME/fzf_key_bindings.bash"
/tmp/fzf/install --bin
cp /tmp/fzf/bin/fzf "$HOME/.local/bin/"
cp /tmp/fzf/bin/fzf-tmux "$HOME/.local/bin/"



# Build dwm, st and slstatus
if [ "$GUI" = "true" ]; then
    cd ~/src
    git clone https://git.suckless.org/dwm
    git clone https://git.suckless.org/st
    git clone https://github.com/ianbeyst/slstatus.git

    cd dwm
    git checkout cb3f58ad06993f7ef3a7d8f61468012e2b786cab
    patch -p1 < "$DFDIR"/patches/dwm-customized-af20849.diff
    make
    make install PREFIX="$HOME/.local"
    make clean

    cd ../st
    git checkout a2c479c
    patch -p1 < "$DFDIR"/patches/st-customized-a2c479c.diff
    make
    make install PREFIX="$HOME/.local"
    make clean

    cd ../slstatus
    for dev in `ls /sys/class/net`; do
        if [ -d "/sys/class/net/$dev/wireless" ]; then WIFIDEV=$(echo $dev); fi;
    done
    sed -i 's/wlp1s0/'$WIFIDEV'/g' config.h
    make
    make install PREFIX="$HOME/.local"
    make clean
    cd ..
fi


# Set up librem configuration that needs root access
if [ "$DEVICE_NAME" = "librem" ] && [ -z "$IS_DOCKER" ]; then
    sudo DFDIR=$DFDIR /bin/sh -c '
        # Make bash history file append only
        chattr +a $DFDIR/data/bash_history

        # Allow group "video" to set backlight brightness
        ln -sfn "$DFDIR/config/udev_backlight.rules /etc/udev/rules.d/backlight.rules

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

        # Automatic webcam capture
        ln -sfn $DFDIR/scripts/webcamshot.sh /usr/local/bin/webcamshot
        echo "* * * * * webcamshot" > /etc/crontabs/$USER

        # Map caps lock to escape in terminals
        ln -sfn $DFDIR/scripts/mapcapslock.sh /etc/local.d/mapcapslock.start
        rc-update add local default
    '
fi



# Clean up
if [ -e "$HOME/.bash_history" ]; then rm "$HOME/.bash_history"; fi
if [ -e "$HOME/.bash_logout" ]; then rm "$HOME/.bash_logout"; fi

