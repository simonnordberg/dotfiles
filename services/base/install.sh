mkdir -p $HOME/.config
mkdir -p $HOME/.local/bin
mkdir -p $HOME/.local/share/applications
mkdir -p $HOME/logs

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
  fuse-libs
