#!/bin/bash
set -x

# Fixes for rodete
xrandr --newmode "1600x900_60.00" 118.25  1600 1696 1856 2112  900 903 908 934 -hsync +vsync
xrandr --addmode eDP-1 1600x900_60.00
echo 160 | sudo tee /sys/devices/platform/i8042/serio1/serio2/sensitivity 