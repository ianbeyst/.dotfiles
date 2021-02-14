#!/bin/sh -e
PROGNAME="$0"
SRCDIR=$(dirname $(readlink -f "$0"))
DFDIR="$SRCDIR/.."


# Read the installation options
. "$DFDIR/install_scripts/install_options"

# Basic setup
setup-keymap us us-dvorak
setup-hostname $NEWHOSTNAME
setup-timezone -z $TIMEZONE
sed "s/IFACE/$IFACE/g" "$DFDIR/install_scripts/interfaces.template" \
    | sed -e "s/HOSTNAME/$NEWHOSTNAME/g" \
    | setup-interfaces -i
apk add wpa_supplicant
sed "s/SSID/$SSID/g" "$DFDIR/install_scripts/wpa_supplicant.conf.template" \
    | sed -e "s/PSK/$PSK/g" \
    > /etc/wpa_supplicant/wpa_supplicant.conf
if [ -z "$IS_DOCKER" ]; then
    wpa_supplicant -B -c /etc/wpa_supplicant/wpa_supplicant.conf -i $IFACE
    udhcpc -i $IFACE
    setup-ntp -c chrony
else
    :> /etc/apk/repositories
fi
setup-apkrepos -1

# Set up repositories (for edge)
sed -i '/v3.13\/main/ s/^/#/' /etc/apk/repositories
sed -i '/edge\/main/ s/^#//' /etc/apk/repositories
sed -i '/edge\/community/ s/^#/@community /' /etc/apk/repositories
sed -i '/edge\/testing/ s/^#/@testing /' /etc/apk/repositories

# Remove tty's
sed -i '/tty[2-9]/ s/^/#/' /etc/inittab

# Remove motd
truncate -s 0 /etc/motd

# Install packages
apk update && apk upgrade
apk add \
    xorg-server@community \
    xf86-video-intel@community \
    xf86-input-libinput@community \
    setxkbmap@community \
    xsetroot@community \
    dmenu@community \
    redshift@community \
    v4l-utils@community \
    ffmpeg@community \
    feh@community \
    zenity@community \
    slock@community \
    ufw@community \
    neovim@community \
    docker@community \
    ip6tables \
    rng-tools \
    sudo \
    eudev \
    gcc \
    make \
    patch \
    git \
    bash-completion \
    perl \
    musl-dev \
    libx11-dev \
    libxft-dev \
    libxinerama-dev \
    libdrm-dev \
    libxkbcommon-dev \
    libxkbcommon-static \
    libinput-dev@community \
    libudev-zero-dev@community \
    wayland-dev \
    wayland-libs-server \
    wayland-protocols \
    pixman-dev \
    pixman-static \
    linux-headers \
    bash \
    pm-utils \
    ttf-dejavu \
    tmux \
    htop \
    ncurses \
    pulseaudio@community \
    pulseaudio-alsa@community \
    alsa-plugins-pulse@community \
    pulseaudio-utils@community \
    acpi \
    procps \
    xdg-utils@community \
    xdg-user-dirs@community \
    openssh \
    e2fsprogs-extra \
    rsync \
    coreutils \
    curl

if [ -z "$IS_DOCKER" ]; then
    # Set up firewall
    ufw default deny incoming
    ufw default deny outgoing
    ufw allow out SSH
    ufw allow out 123/udp
    ufw allow out DNS
    ufw allow out 80/tcp
    ufw allow out 443
    ufw enable
    service ufw start

    # Set up services
    setup-udev
    rc-update add urandom boot
    rc-update add rngd boot
    rc-update add wpa_supplicant boot
    rc-update add ufw boot
    rc-update add docker boot
    rc-update add crond default
    rc-update add alsa default
    rc-update add acpid default
    rc-update del networking boot
    rc-update -u
fi

# Set up users and groups
GROUPNAME="$USERNAME"
addgroup -g 1000 -S "$GROUPNAME"
adduser -G "$GROUPNAME" -S -u 1000 -s /bin/bash $USERNAME
if [ -z "$IS_DOCKER" ]; then
    passwd
else
    passwd << EOF
123456789
123456789
EOF
    passwd $USERNAME << EOF
123456789
123456789
EOF
fi
# addgroup root audio
addgroup $USERNAME video
addgroup $USERNAME audio
addgroup $USERNAME docker
addgroup $USERNAME input
addgroup $USERNAME wheel

echo '%wheel ALL=(ALL) ALL' | sudo EDITOR='tee -a' visudo



if [ -z "$IS_DOCKER" ]; then
    # Perform the installation
    export BOOT_SIZE=$BOOT_SIZE
    setup-disk -m sys -s $SWAP_SIZE $INSTALL_DISK

    # Create the user's home directory on the installation disk
    mount -t ext4 "$INSTALL_DISK"p3 /mnt
    mkdir "/mnt/home/$USERNAME"
    chown -R "$USERNAME":"$GROUPNAME" "/mnt/home/$USERNAME"
else
    chown -R "$USERNAME":"$GROUPNAME" "/home/$USERNAME"
fi

