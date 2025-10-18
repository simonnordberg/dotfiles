#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

mkdir -p $HOME/.config/pipewire
cp $SCRIPT_DIR/pipewire.conf $HOME/.config/pipewire/pipewire.conf

systemctl --user restart pipewire.service

echo "Pipewire customizations installed!"
