#!/bin/sh
TIMESTAMP=$(date +%s)
ffmpeg -f v4l2 -i /dev/video0 -vframes 1 "/home/$USER/data/webcam/$TIMESTAMP.jpg"
