SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

sudo dnf install -y fish
sudo chsh -s $(which fish) $USER

curl -sS https://starship.rs/install.sh | sh -s -- -y


rm -rf $HOME/.config/fish
rsync -r --delete $SCRIPT_DIR/fish/ $HOME/.config/fish/

rm -f $HOME/.config/starship.toml
cp $SCRIPT_DIR/starship.toml $HOME/.config/starship.toml
