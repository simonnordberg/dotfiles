SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

sudo dnf copr enable avengemedia/dms -y
sudo dnf copr enable yalter/niri -y
sudo dnf copr enable sdegler/hyprland -y
sudo dnf install niri dms hyprlock -y
systemctl --user add-wants niri.service dms

mkdir -p $HOME/.config/niri
cp $SCRIPT_DIR/config.kdl $HOME/.config/niri/config.kdl

mkdir -p $HOME/.config/hypr
cp $SCRIPT_DIR/hyprlock.conf $HOME/.config/hypr/hyprlock.conf
