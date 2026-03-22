sudo dnf install -y gdm

sudo systemctl enable gdm
sudo systemctl set-default graphical.target
sudo usermod -a -G video $USER

# Disable suspend
sudo systemctl mask suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target
