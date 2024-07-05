#!/usr/bin/env bash

set -e

if [ "$EUID" -eq 0 ]; then
    echo "Please don't run as root"
    exit
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PRELUDE_DIR="$HOME/.emacs.d"
FONTS_DIR="$HOME/.local/share/fonts/"
PRELUDE_INSTALL="https://github.com/bbatsov/prelude/raw/master/utils/installer.sh"
FONT_AWESOME_INSTALL="https://use.fontawesome.com/releases/v6.5.1/fontawesome-free-6.5.1-desktop.zip"

echo "Linking misc config"
ln -fsn $SCRIPT_DIR/bin $HOME/bin
ln -fsn $SCRIPT_DIR/.gitconfig $HOME/.gitconfig
ln -fsn $SCRIPT_DIR/.vimrc $HOME/.vimrc
ln -fsn $SCRIPT_DIR/.vim_runtime $HOME/.vim_runtime

curl -Lo $HOME/bin/theme.sh https://git.io/JM70M && chmod +x $HOME/bin/theme.sh

[[ ! -d $PRELUDE_DIR ]] && curl -L $PRELUDE_INSTALL | sh
ln -fsn $SCRIPT_DIR/.emacs.d/personal/config.el $HOME/.emacs.d/personal/config.el

systemctl --user mask tracker-extract-3.service \
          tracker-miner-fs-3.service \
          tracker-miner-rss-3.service \
          tracker-writeback-3.service \
          tracker-xdg-portal-3.service \
          tracker-miner-fs-control-3.service
tracker3 reset -s -r

mkdir -p $HOME/logs
mkdir -p $HOME/.config

ln -fsn $SCRIPT_DIR/.config/sway $HOME/.config/sway
ln -fsn $SCRIPT_DIR/.config/i3 $HOME/.config/i3
ln -fsn $SCRIPT_DIR/.config/i3status $HOME/.config/i3status
ln -fsn $SCRIPT_DIR/.config/mako $HOME/.config/mako
ln -fsn $SCRIPT_DIR/.config/foot $HOME/.config/foot
ln -fsn $SCRIPT_DIR/.config/waybar $HOME/.config/waybar
ln -fsn $SCRIPT_DIR/.config/wofi $HOME/.config/wofi
ln -fsn $SCRIPT_DIR/.config/alacritty $HOME/.config/alacritty

mkdir -p $HOME/.config/systemd/user
ln -fsn $SCRIPT_DIR/.config/systemd/user/emacs.service $HOME/.config/systemd/user/emacs.service
systemctl --user is-active emacs && systemctl --user restart emacs || systemctl --user enable --now emacs

mkdir -p $HOME/.config/autostart
ln -fsn $SCRIPT_DIR/.config/autostart/nvidia-force-full-composition.desktop $HOME/.config/autostart
ln -fsn /usr/share/applications/mullvad-vpn.desktop $HOME/.config/autostart

[[ -e $HOME/.oh-my-zsh/ ]] && rm -rf $HOME/.oh-my-zsh/
[[ -e $HOME/.zshrc ]] && rm -f $HOME/.zshrc

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/mroth/evalcache $HOME/.oh-my-zsh/custom/plugins/evalcache
git clone https://github.com/lukechilds/zsh-nvm $HOME/.oh-my-zsh/custom/plugins/zsh-nvm

ln -fsn $SCRIPT_DIR/.zshrc $HOME/.zshrc
ln -fsn $SCRIPT_DIR/.profile $HOME/.profile
ln -fsn $SCRIPT_DIR/.zprofile $HOME/.zprofile

echo "All done!"
