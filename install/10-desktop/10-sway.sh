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
  bemenu

mkdir -p $HOME/.config
ln -fsn $SCRIPT_DIR/.config/sway $HOME/.config/sway
ln -fsn $SCRIPT_DIR/.config/waybar $HOME/.config/waybar
ln -fsn $SCRIPT_DIR/.config/mako $HOME/.config/mako

sudo cp $SCRIPT_DIR/root/usr/share/wayland-sessions/sway-wrapper.desktop /usr/share/wayland-sessions/sway-wrapper.desktop
sudo cp $SCRIPT_DIR/root/usr/local/bin/sway-wrapper /usr/local/bin/sway-wrapper
