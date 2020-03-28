#!/bin/sh
MAXBRIGHTNESS=$(cat /sys/class/backlight/intel_backlight/max_brightness)
let "b = $1 * $MAXBRIGHTNESS / 100"
echo $b > /sys/class/backlight/intel_backlight/brightness
