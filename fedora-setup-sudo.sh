#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

dnf config-manager --add-repo https://repository.mullvad.net/rpm/beta/mullvad.repo
dnf update -y
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
    openssl-devel \
    dnf-plugins-core \
    mullvad-vpn

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# User needs to be in video group to change brightness
usermod -a -G video simon

# echo "Installing wayland stuff (copy)"
cp $SCRIPT_DIR/root/usr/share/wayland-sessions/sway-wrapper.desktop \
   /usr/share/wayland-sessions/sway-wrapper.desktop

echo "Installing etc config"
ln -fsn $SCRIPT_DIR/root/usr/local/bin/ssway /usr/local/bin/ssway

echo "Configuring fstab"
cp /etc/fstab "/etc/fstab.backup.$(date +%Y%m%d%H%M%S)"
PARTIAL_FSTAB="$SCRIPT_DIR/root/etc/fstab.partial"
START_MARKER="# Begin Custom Mounts"
END_MARKER="# End Custom Mounts"

{
    echo "$START_MARKER"
    cat "$PARTIAL_FSTAB"
    echo "$END_MARKER"
} >> /etc/fstab

echo "Now remember to install the user stuff, i.e. $SCRIPT_DIR/fedora-setup.sh"
