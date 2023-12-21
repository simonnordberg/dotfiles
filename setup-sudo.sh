#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

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

if [ $swap -lt $mem ]; then
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
