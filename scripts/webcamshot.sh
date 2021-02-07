#!/bin/sh
ffmpeg -f v4l2 -i /dev/video0 -vframes 1 /home/io/data/webcam/$(date +%s).jpg
