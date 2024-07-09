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
