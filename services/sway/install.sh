SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

sudo dnf install -y \
  brightnessctl \
  dex-autostart \
  pavucontrol \
  sway \
  swayidle \
  swaylock \
  waybar \
  wl-clipboard \
  pulseaudio-utils \
  slurp \
  j4-dmenu-desktop \
  bemenu \
  google-noto-color-emoji-fonts \
  mako \
  rofi-wayland

rm -rf $HOME/.config/sway
rm -rf $HOME/.config/waybar
rm -rf $HOME/.config/mako
rm -rf $HOME/.config/rofi

rsync -r --delete $SCRIPT_DIR/sway/ $HOME/.config/sway/
rsync -r --delete $SCRIPT_DIR/waybar/ $HOME/.config/waybar/
rsync -r --delete $SCRIPT_DIR/mako/ $HOME/.config/mako/
rsync -r --delete $SCRIPT_DIR/rofi/ $HOME/.config/rofi/

sudo cp $SCRIPT_DIR/sway-wrapper.desktop /usr/share/wayland-sessions/sway-wrapper.desktop
sudo cp $SCRIPT_DIR/sway-wrapper /usr/local/bin/sway-wrapper
