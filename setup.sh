#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export PRELUDE_INSTALL_DIR="$HOME/.emacs.d"
export PRELUDE_INSTALL="https://github.com/bbatsov/prelude/raw/master/utils/installer.sh"

if [ "$EUID" -eq 0 ]; then
    echo "Please don't run as root"
    exit
fi

echo "Linking misc config"
ln -sn $SCRIPT_DIR/bin $HOME/bin
ln -sn $SCRIPT_DIR/.zshrc $HOME/.zshrc
ln -sn $SCRIPT_DIR/.profile $HOME/.profile
ln -sn $SCRIPT_DIR/.zprofile $HOME/.zprofile
ln -sn $SCRIPT_DIR/.gitconfig $HOME/.gitconfig
ln -sn $SCRIPT_DIR/.vimrc $HOME/.vimrc
ln -sn $SCRIPT_DIR/.vim_runtime $HOME/.vim_runtime

if [ ! -d "$PRELUDE_INSTALL_DIR" ]; then
    echo "Installing Prelude"
    curl -L $PRELUDE_INSTALL | sh
else
    echo "Prelude already installed"
fi

echo "Configuring emacs"
ln -sn $SCRIPT_DIR/.emacs.d/personal/theme.el \
   $HOME/.emacs.d/personal/theme.el

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
ln -sn $SCRIPT_DIR/.config/i3 $HOME/.config/i3
ln -sn $SCRIPT_DIR/.config/mako $HOME/.config/mako
ln -sn $SCRIPT_DIR/.config/foot $HOME/.config/foot
ln -sn $SCRIPT_DIR/.config/waybar $HOME/.config/waybar

echo "Linking alacritty stuff, remember to install the terminfo"
echo "See https://github.com/alacritty/alacritty/blob/master/INSTALL.md#post-build"
ln -sn $SCRIPT_DIR/.config/alacritty $HOME/.config/alacritty

echo "Configuring autostart"
mkdir -p $HOME/.config/systemd/user
ln -sn $SCRIPT_DIR/.config/systemd/user/emacs.service \
   $HOME/.config/systemd/user/emacs.service
ln -sn $SCRIPT_DIR/.config/systemd/user/mullvad-gui.service \
   $HOME/.config/systemd/user/mullvad-gui.service
systemctl --user enable emacs mullvad-gui

echo "Configuring shell"
if [ ! -d $HOME/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [ ! -d $HOME/.oh-my-zsh/custom/plugins/evalcache ]; then
    git clone https://github.com/mroth/evalcache \
        $HOME/.oh-my-zsh/custom/plugins/evalcache
fi

if [ ! -d $HOME/.oh-my-zsh/custom/plugins/zsh-nvm ]; then
    git clone https://github.com/lukechilds/zsh-nvm \
        $HOME/.oh-my-zsh/custom/plugins/zsh-nvm
fi

echo "Now remember to install the system wide stuff, i.e. sudo $SCRIPT_DIR/setup-sudo.sh"
