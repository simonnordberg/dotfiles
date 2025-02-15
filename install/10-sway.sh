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
  kanshi

mkdir -p $HOME/.config
ln -fsn $BASE_DIR/.config/sway $HOME/.config/sway
ln -fsn $BASE_DIR/.config/waybar $HOME/.config/waybar
ln -fsn $BASE_DIR/.config/mako $HOME/.config/mako
ln -fsn $BASE_DIR/.config/kanshi $HOME/.config/kanshi
ln -fsn $BASE_DIR/.config/systemd/user/kanshi.service $HOME/.config/systemd/user/kanshi.service

systemctl --user enable kanshi.service

sudo cp $BASE_DIR/root/usr/share/wayland-sessions/sway-wrapper.desktop /usr/share/wayland-sessions/sway-wrapper.desktop
sudo cp $BASE_DIR/root/usr/local/bin/sway-wrapper /usr/local/bin/sway-wrapper
