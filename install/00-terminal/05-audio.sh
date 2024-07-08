sudo dnf install -y pipewire

rm -rf $HOME/.config/pipewire
ln -fsn $SCRIPT_DIR/.config/pipewire $HOME/.config/pipewire
ln -fsn $SCRIPT_DIR/.config/pipewire $HOME/.config/pipewire