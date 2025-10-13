#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

mkdir -p $HOME/.config/hypr

echo "Installing Hyprland configuration overrides..."

for config_file in "$SCRIPT_DIR"/*.conf; do
  if [ -f "$config_file" ]; then
    filename=$(basename "$config_file")
    echo "  Installing $filename"
    cp "$config_file" "$HOME/.config/hypr/$filename"
  fi
done

echo "Hyprland customizations installed!"
