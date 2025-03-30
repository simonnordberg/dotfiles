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

ln -fsn $BASE_DIR/.config/sway $HOME/.config/sway
ln -fsn $BASE_DIR/.config/waybar $HOME/.config/waybar
ln -fsn $BASE_DIR/.config/mako $HOME/.config/mako
ln -fsn $BASE_DIR/.config/rofi $HOME/.config/rofi

sudo cp $BASE_DIR/root/usr/share/wayland-sessions/sway-wrapper.desktop /usr/share/wayland-sessions/sway-wrapper.desktop
sudo cp $BASE_DIR/root/usr/local/bin/sway-wrapper /usr/local/bin/sway-wrapper
