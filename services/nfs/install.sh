#!/bin/bash

sudo mkdir -p /mnt/media /mnt/home

add_mount() {
    local source=$1
    local mountpoint=$2
    local opts="soft,timeo=150,retrans=3,rsize=1048576,wsize=1048576,_netdev,x-systemd.automount,x-systemd.idle-timeout=60min"

    if ! grep -q "^${source}" /etc/fstab; then
        echo "${source} ${mountpoint} nfs ${opts} 0 0" | sudo tee -a /etc/fstab >/dev/null
    fi
}

add_mount "nas01:/volume1/media" "/mnt/media"
add_mount "nas01:/volume1/homes/simon" "/mnt/home"

sudo systemctl daemon-reload
sudo mount -a