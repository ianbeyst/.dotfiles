#!/bin/sh
v4l2-ctl --set-ctrl=exposure_auto_priority=0
v4l2-ctl --set-ctrl=exposure_auto=1
v4l2-ctl --set-ctrl=exposure_absolute=78
v4l2-ctl --set-ctrl=gain=0
ffmpeg -f v4l2 -i /dev/video0 -vframes 1 /home/io/data/webcam/$(date +%s).jpg
