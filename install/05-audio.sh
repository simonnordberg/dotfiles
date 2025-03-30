sudo dnf install -y pipewire

rm -rf $HOME/.config/pipewire
ln -fsn $BASE_DIR/.config/pipewire $HOME/.config/pipewire
