#!/bin/sh
skypeforlinux
while true
do
    pgrep skypeforlinux | read REPLY || break
    sleep 1
done
