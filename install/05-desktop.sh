sudo dnf install -y gdm

sudo systemctl enable gdm
sudo systemctl set-default graphical.target
sudo usermod -a -G video $USER
