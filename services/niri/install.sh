SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

sudo dnf copr enable avengemedia/dms -y
sudo dnf copr enable yalter/niri -y
sudo dnf install niri dms -y
systemctl --user add-wants niri.service dms

mkdir -p $HOME/.config/niri
cp $SCRIPT_DIR/config.kdl $HOME/.config/niri/config.kdl
