sudo dnf install -y gdm

sudo systemctl enable gdm
sudo systemctl set-default graphical.target
sudo usermod -a -G video $USER

# Enable GDM auto-login when LUKS is enabled (password already entered at boot)
if [ -f /etc/crypttab ] && sudo grep -qvE '^(#|$)' /etc/crypttab 2>/dev/null; then
  sudo mkdir -p /etc/gdm
  sudo tee /etc/gdm/custom.conf > /dev/null <<EOF
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=$USER
EOF
fi
