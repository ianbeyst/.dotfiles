#!/bin/sh
logger "Lid closed, suspending..."
su -l -s /bin/sh io -c 'export DISPLAY=:0; slock' &
pm-suspend
