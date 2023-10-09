#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export PRELUDE_INSTALL_DIR="$HOME/.emacs.d"
export PRELUDE_INSTALL="https://github.com/bbatsov/prelude/raw/master/utils/installer.sh"

if [ "$EUID" -eq 0 ]; then
    echo "Please don't run as root"
    exit
fi

echo "Linking misc config"
ln -sn $SCRIPT_DIR/.gitconfig $HOME/.gitconfig
ln -sn $SCRIPT_DIR/.vimrc $HOME/.vimrc
ln -sn $SCRIPT_DIR/.vim_runtime $HOME/.vim_runtime

if [ ! -d "$PRELUDE_INSTALL_DIR" ]; then
    echo "Installing Prelude"
    curl -L $PRELUDE_INSTALL | sh
else
    echo "Prelude already installed"
fi

echo "Disabling tracker3"
systemctl --user mask tracker-extract-3.service \
          tracker-miner-fs-3.service \
          tracker-miner-rss-3.service \
          tracker-writeback-3.service \
          tracker-xdg-portal-3.service \
          tracker-miner-fs-control-3.service
tracker3 reset -s -r

echo "Linking config files"
mkdir -p $HOME/.config
ln -sn $SCRIPT_DIR/.config/sway $HOME/.config/sway
ln -sn $SCRIPT_DIR/.config/mako $HOME/.config/mako
ln -sn $SCRIPT_DIR/.config/foot $HOME/.config/foot
ln -sn $SCRIPT_DIR/.config/waybar $HOME/.config/waybar

mkdir -p $HOME/.config/systemd/user
ln -sn $SCRIPT_DIR/.config/systemd/user/emacs.service $HOME/.config/systemd/user/emacs.service

