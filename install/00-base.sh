# Common directories
mkdir -p $HOME/.config
mkdir -p $HOME/.local/bin
mkdir -p $HOME/.local/share/applications
mkdir -p $HOME/logs

# Extend root partition to fill the disk
sudo lvextend -l +100%FREE /dev/mapper/fedora-root
sudo xfs_growfs /dev/mapper/fedora-root

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
