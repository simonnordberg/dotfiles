sudo dnf install -y pipewire

export SERVICE_DIR="$(dirname "$(readlink -f "$0")")"

[ -L $HOME/.config/pipewire ] && rm $HOME/.config/pipewire

mkdir -p "$HOME/.config/pipewire"
cp $SERVICE_DIR/pipewire.conf $HOME/.config/pipewire/pipewire.conf
