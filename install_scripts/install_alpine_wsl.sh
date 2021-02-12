#!/bin/sh

# Remove motd
truncate -s 0 /etc/motd

# Install packages
apk update && apk upgrade
apk add \
    fzf \
    fzf-bash-completion \
    neovim \
    sudo \
    bash-completion \
    bash \
    tmux \
    htop \
    xdg-utils \
    xdg-user-dirs \
    rsync \
    coreutils \
    perl

# Set up user
addgroup $USERNAME wheel
addgroup $USERNAME docker
visudo

# Use bash as login shell
sed -i "s+/home/$USERNAME:/bin/ash+/home/$USERNAME:/bin/bash+g" /etc/passwd

