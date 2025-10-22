#!/bin/bash

# Import DISPLAY into systemd user environment for GTK portal services
systemctl --user import-environment DISPLAY

# Kill any existing picom instances
pkill picom

# Start picom compositor to prevent screen tearing
picom --config ~/.config/picom/picom.conf &
