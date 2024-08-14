sudo dnf install -y pipewire

mkdir -p $HOME/.config
rm -rf $HOME/.config/pipewire
ln -fsn $BASE_DIR/.config/pipewire $HOME/.config/pipewire
