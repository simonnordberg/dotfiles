#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

add-apt-repository -y universe
add-apt-repository -y ppa:graphics-drivers/ppa
apt install -y curl

if [[ ! -f /usr/share/keyrings/mullvad-keyring.asc ]]; then
    curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc
    echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$( dpkg --print-architecture )] https://repository.mullvad.net/deb/beta $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/mullvad.list
fi

if [[ ! -f /usr/share/keyrings/1password-archive-keyring.gpg ]]; then
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list

    mkdir -p /etc/debsig/policies/AC2D62742012EA22/
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol

    mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
fi

apt update
apt install -y \
    zsh \
    sway \
    swayidle \
    swaylock \
    waybar \
    fzf \
    emacs \
    nfs-common \
    flatpak \
    mullvad-vpn \
    dex \
    pavucontrol \
    brightnessctl \
    slurp \
    grim \
    wl-clipboard \
    1password \
    fonts-font-awesome \
    libfuse2 \
    xdg-desktop-portal \
    xdg-desktop-portal-wlr \
    xdg-desktop-portal-gtk \
    wofi \
    fonts-roboto \
    xserver-xorg-video-nouveau

flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# User needs to be in video group to change brightness
usermod -a -G video simon

# echo "Installing wayland stuff (copy)"
cp $SCRIPT_DIR/root/usr/share/wayland-sessions/ubuntu-sway.desktop /usr/share/wayland-sessions/ubuntu-sway.desktop

echo "Installing etc config"
ln -sn $SCRIPT_DIR/root/etc/initramfs-tools/conf.d/resume /etc/initramfs-tools/conf.d/resume
ln -sn $SCRIPT_DIR/root/etc/systemd/sleep.conf /etc/systemd/sleep.conf
ln -sn $SCRIPT_DIR/root/etc/systemd/logind.conf /etc/systemd/logind.conf
ln -sn $SCRIPT_DIR/root/usr/local/bin/ssway /usr/local/bin/ssway

mem=$(awk '/MemTotal/{ print $2 }' /proc/meminfo)
swap=$(awk '/partition/{ print $3 }' /proc/swaps)

echo "Memory size: $mem"
echo "Swap size: $swap"

if [[ $swap -lt $mem ]]; then
    echo "Swap partition need to be at least as large as the memory size."
    echo "Resize and try again."
    exit
fi

echo "Trying to update the resume block id"
swapuuid=$(blkid | grep swap | grep -oP ' UUID="\K[^"]+')

if [[ $swapuuid ]]; then
    echo "resume=UUID=$swapblkid" > $SCRIPT_DIR/root/etc/initramfs-tools/conf.d/resume
    update-initramfs -u -k all
fi
