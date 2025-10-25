#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

mkdir -p $HOME/.config/waybar
cp $SCRIPT_DIR/config.jsonc $HOME/.config/waybar/config.jsonc

echo "Waybar customizations installed!"
