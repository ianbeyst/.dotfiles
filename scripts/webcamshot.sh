#!/bin/sh
v4l2-ctl --set-ctrl=hue=-35
v4l2-ctl --set-ctrl=exposure_auto_priority=0
v4l2-ctl --set-ctrl=exposure_auto=01
v4l2-ctl --set-ctrl=white_balance_temperature_auto=0
v4l2-ctl --set-ctrl=white_balance_temperature=6500
v4l2-ctl --set-ctrl=exposure_absolute=78
ffmpeg -f v4l2 -i /dev/video0 -vframes 1 /home/io/data/webcam/$(date +%s).jpg
