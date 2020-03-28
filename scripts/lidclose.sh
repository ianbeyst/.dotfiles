#!/bin/sh
logger "Lid closed, suspending..."
su -l io -c 'export DISPLAY=:0; slock' &
pm-suspend
