mkdir -p $HOME/.config
mkdir -p $HOME/.local/bin
mkdir -p $HOME/.local/share/applications
mkdir -p $HOME/logs

# Extend sudo timeout to 8 hours (invalidated on screen lock)
sudo cp $SCRIPT_DIR/sudo-timeout /etc/sudoers.d/timeout
sudo chmod 440 /etc/sudoers.d/timeout

# Invalidate sudo credentials on screen lock
mkdir -p $HOME/.config/systemd/user
cp $SCRIPT_DIR/sudo-invalidate-on-lock $HOME/.local/bin/sudo-invalidate-on-lock
cp $SCRIPT_DIR/sudo-invalidate-on-lock.service $HOME/.config/systemd/user/sudo-invalidate-on-lock.service
systemctl --user daemon-reload
systemctl --user enable --now sudo-invalidate-on-lock.service

# Extend root partition to fill the disk
if command -v lvs >/dev/null 2>&1; then
  ROOT_LV=$(sudo lvs --noheadings -o lv_path | grep -E '/root$' | tr -d ' ')
  if [ -n "$ROOT_LV" ] && [ -e "$ROOT_LV" ]; then
    sudo lvextend -l +100%FREE "$ROOT_LV"
    sudo xfs_growfs "$ROOT_LV"
  fi
fi

# Install packages
sudo dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf update -y
sudo dnf install -y \
  curl \
  git \
  openssl-devel \
  dnf-plugins-core \
  fuse \
  fuse-libs \
  btop
