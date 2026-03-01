SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

sudo dnf copr enable scottames/ghostty -y
sudo dnf install ghostty -y

mkdir -p $HOME/.config/ghostty
cp $SCRIPT_DIR/config $HOME/.config/ghostty/config
