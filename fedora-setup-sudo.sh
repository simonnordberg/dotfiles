#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

# Fedora equivalent of adding repositories and installing some basic packages
dnf install -y dnf-plugins-core
dnf config-manager --set-enabled rpmfusion-free
dnf config-manager --add-repo=https://download.nvidia.com/fedora$(rpm -E %fedora)/nvidia-driver.repo
dnf install -y curl

# Mullvad VPN and 1Password require manual setup since they are not in Fedora repositories
# Consider downloading RPMs directly or using flatpak for these if available

# Mullvad VPN setup
if [[ ! -f /etc/pki/rpm-gpg/mullvad-vpn.pub ]]; then
    curl -fsSLo /etc/pki/rpm-gpg/mullvad-vpn.pub https://mullvad.net/media/mullvad-vpn-fedora.pub
    rpm --import /etc/pki/rpm-gpg/mullvad-vpn.pub
    echo "[mullvad-vpn]
name=Mullvad VPN
baseurl=https://mullvad.net/download/rpm/\$releasever/\$basearch
enabled=1
metadata_expire=1d
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/mullvad-vpn.pub
skip_if_unavailable=True" > /etc/yum.repos.d/mullvad-vpn.repo
fi

# 1Password does not have an official Fedora repo. Consider using flatpak or direct RPM install

dnf update -y

# Install packages. Replace or omit those not available or needed differently in Fedora
dnf install -y \
    emacs \
    flatpak \
    google-roboto-fonts \
    fzf \
    fuse \
    nfs-utils \
    pavucontrol \
    sway \
    swayidle \
    swaylock \
    waybar \
    wl-clipboard \
    wofi \
    zsh \
    google-roboto-fonts \
    xorg-x11-drv-nouveau \
    openssl-devel

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# User management commands remain the same
usermod -a -G video simon

# System configuration files may need different handling on Fedora
# Ensure compatibility or necessity of each operation in Fedora context

# Example: Copy wayland session setup
cp $SCRIPT_DIR/root/usr/share/wayland-sessions/ubuntu-sway.desktop /usr/share/wayland-sessions/ubuntu-sway.desktop

# Swap configuration remains largely the same, but check for Fedora specifics in system file paths or commands
mem=$(awk '/MemTotal/{ print $2 }' /proc/meminfo)
swap=$(awk '/SwapTotal/{ print $2 }' /proc/meminfo) # Changed to SwapTotal for consistency

echo "Memory size: $mem"
echo "Swap size: $swap"

if [[ $swap -lt $mem ]]; then
    echo "Swap partition needs to be at least as large as the memory size."
    echo "Resize and try again."
    exit
fi

# Update resume block ID, ensuring compatibility with Fedora's initramfs update commands
echo "Trying to update the resume block id"
swapuuid=$(blkid | grep swap | grep -oP ' UUID="\K[^"]+')

if [[ $swapuuid ]]; then
    echo "resume=UUID=$swapuuid" > /etc/default/grub
    grub2-mkconfig -o /boot/grub2/grub.cfg
    dracut -f --regenerate-all
fi

echo "Now remember to install the user stuff, i.e. $SCRIPT_DIR/fedora-setup.sh"
