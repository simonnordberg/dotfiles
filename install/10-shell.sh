CONFIG_DIR=$HOME/.config/fish

sudo dnf install -y fish
sudo chsh -s $(which fish) $USER

curl -sS https://starship.rs/install.sh | sh -s -- -y

[ -e $CONFIG_DIR ] && rm -rf $CONFIG_DIR
ln -fsn $SCRIPT_DIR/.config/fish $CONFIG_DIR

ln -fsn $SCRIPT_DIR/.config/starship.toml $HOME/.config/starship.toml
