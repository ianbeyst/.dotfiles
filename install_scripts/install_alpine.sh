#!/bin/sh

. install_options

setup-keymap us us-dvorak
setup-hostname $NEWHOSTNAME
sed "s/IFACE/$IFACE/g" interfaces.template \
    | sed -e "s/HOSTNAME/$NEWHOSTNAME/g" \
    | setup-interfaces -i
apk add wpa_supplicant
sed "s/SSID/$SSID/g" wpa_supplicant.conf.template \
    | sed -e "s/PSK/$PSK/g" \
    > wpa_supplicant.conf
cp wpa_supplicant.conf /etc/wpa_supplicant/
wpa_supplicant -B -c /etc/wpa_supplicant/wpa_supplicant.conf -i $IFACE
setup-timezone -z $TIMEZONE
passwd
setup-ntp -c chrony
setup-apkrepos -1
