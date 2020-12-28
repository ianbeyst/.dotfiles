#!/bin/sh

# Read the installation options
. install_options

# Basic setup
setup-keymap us us-dvorak
setup-hostname $NEWHOSTNAME
sed "s/IFACE/$IFACE/g" interfaces.template \
    | sed -e "s/HOSTNAME/$NEWHOSTNAME/g" \
    | setup-interfaces -i
apk add wpa_supplicant
sed "s/SSID/$SSID/g" wpa_supplicant.conf.template \
    | sed -e "s/PSK/$PSK/g" \
    > /etc/wpa_supplicant/wpa_supplicant.conf
wpa_supplicant -B -c /etc/wpa_supplicant/wpa_supplicant.conf -i $IFACE
udhcpc -i $IFACE
setup-timezone -z $TIMEZONE
setup-ntp -c chrony
setup-apkrepos -1
passwd

# Set up repositories (for edge)
sed -i '/v3.12\/main/ s/^/#/' /etc/apk/repositories
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
    firefox@community \
    dmenu@community \
    redshift@community \
    fzf@community \
    fzf-bash-completion@community \
    v4l-utils@community \
    ffmpeg@community \
    feh@community \
    zenity@community \
    slock@community \
    ufw@community \
    neovim@community \
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
    linux-headers \
    bash \
    pm-utils \
    ttf-dejavu \
    tmux \
    htop \
    ncurses \
    alsa-utils \
    alsa-lib \
    alsaconf \
    acpi

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
rc-update add crond default
rc-update add alsa default
rc-update add acpid default
rc-update del networking boot
rc-update -u

# Set up user
adduser -G wheel $USERNAME
addgroup root video
addgroup root audio
addgroup $USERNAME video
addgroup $USERNAME audio
visudo

# Use bash as login shell
sed -i "s+/home/$USERNAME:/bin/ash+/home/$USERNAME:/bin/bash+g" /etc/passwd

# Perform the installation
export BOOT_SIZE=$BOOT_SIZE
setup-disk -m sys -s $SWAP_SIZE $INSTALL_DISK

# Create the user's home directory on the installation disk
mount -t ext4 ${INSTALL_DISK}p3 /mnt
mkdir /mnt/home/$USERNAME
chown -R $USERNAME /mnt/home/$USERNAME
