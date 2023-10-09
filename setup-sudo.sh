#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

echo "Installing helper binaries"
ln -sn $SCRIPT_DIR/root/usr/local/bin/rubymine /usr/local/bin/rubymine
ln -sn $SCRIPT_DIR/root/usr/local/bin/idea /usr/local/bin/idea
ln -sn $SCRIPT_DIR/root/usr/local/bin/pycharm /usr/local/bin/pycharm
ln -sn $SCRIPT_DIR/root/usr/local/bin/fp /usr/local/bin/fp

echo "Installing etc config"
ln -sn $SCRIPT_DIR/root/etc/initramfs-tools/conf.d/resume /etc/initramfs-tools/conf.d/resume
ln -sn $SCRIPT_DIR/root/etc/systemd/sleep.conf /etc/systemd/sleep.conf
ln -sn $SCRIPT_DIR/root/etc/systemd/logind.conf /etc/systemd/logind.conf

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
