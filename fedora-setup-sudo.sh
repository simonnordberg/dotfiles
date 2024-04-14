#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

if [[ ! -f /etc/yum.repos.d/1password.repo ]]; then
    rpm --import https://downloads.1password.com/linux/keys/1password.asc
    sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
fi

dnf install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

dnf config-manager --add-repo https://repository.mullvad.net/rpm/beta/mullvad.repo
dnf update -y
dnf install -y \
    brightnessctl \
    dex-autostart \
    emacs \
    flatpak \
    google-roboto-fonts \
    google-noto-color-emoji-fonts \
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
    openssl-devel \
    dnf-plugins-core \
    mullvad-vpn \
    pulseaudio-utils \
    gdm \
    1password

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

systemctl enable gdm
systemctl set-default graphical.target

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

sed -i "/$START_MARKER/,/$END_MARKER/d" /etc/fstab

{
    echo "$START_MARKER"
    cat "$PARTIAL_FSTAB"
    echo "$END_MARKER"
} >> /etc/fstab

echo "Now remember to install the user stuff, i.e. $SCRIPT_DIR/fedora-setup.sh"
