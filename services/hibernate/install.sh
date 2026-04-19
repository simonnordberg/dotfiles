#!/bin/bash

set -e

CHASSIS="$(hostnamectl chassis 2>/dev/null || echo "desktop")"
if [ "$CHASSIS" != "laptop" ] && [ "$CHASSIS" != "notebook" ]; then
  echo "Skipping hibernate setup (chassis: $CHASSIS)"
  exit 0
fi

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
SWAPFILE="/swapfile"
RAM_MB=$(awk '/MemTotal/{printf "%d", $2/1024}' /proc/meminfo)
SWAP_SIZE_MB=$(( RAM_MB + 2048 ))  # RAM + 2 GB margin

# Create swap file if it doesn't exist
if [ ! -f "$SWAPFILE" ]; then
  echo "Creating swap file (${SWAP_SIZE_MB}M for ${RAM_MB}M RAM)..."
  sudo fallocate -l "${SWAP_SIZE_MB}M" "$SWAPFILE"
  sudo chmod 600 "$SWAPFILE"
  sudo mkswap "$SWAPFILE"
fi

# Enable swap if not already active
if ! swapon --show | grep -q "$SWAPFILE"; then
  sudo swapon "$SWAPFILE"
fi

# Add to fstab if not present (low priority so zram is preferred for normal use)
if ! grep -q "$SWAPFILE" /etc/fstab; then
  echo "$SWAPFILE none swap sw,pri=1 0 0" | sudo tee -a /etc/fstab
fi

# Get resume device and offset
RESUME_DEVICE=$(findmnt -no SOURCE -T "$SWAPFILE")
RESUME_OFFSET=$(sudo filefrag -v "$SWAPFILE" | awk '/ 0:/{print substr($4, 1, length($4)-2)}')

if [ -z "$RESUME_OFFSET" ]; then
  echo "ERROR: Could not determine resume offset"
  exit 1
fi

echo "Resume device: $RESUME_DEVICE"
echo "Resume offset: $RESUME_OFFSET"

# Remove any stale resume args before setting new ones
sudo grubby --update-kernel=ALL --remove-args="resume resume_offset"
sudo grubby --update-kernel=ALL --args="resume=$RESUME_DEVICE resume_offset=$RESUME_OFFSET"

# Install systemd config drop-ins
sudo mkdir -p /etc/systemd/sleep.conf.d /etc/systemd/logind.conf.d
sudo cp "$SCRIPT_DIR/sleep.conf" /etc/systemd/sleep.conf.d/hibernate.conf
sudo cp "$SCRIPT_DIR/logind.conf" /etc/systemd/logind.conf.d/hibernate.conf

# Ensure dracut includes the resume module — rebuild initramfs only if config changed
sudo mkdir -p /etc/dracut.conf.d
if ! diff -q "$SCRIPT_DIR/dracut-resume.conf" /etc/dracut.conf.d/resume.conf &>/dev/null; then
  sudo cp "$SCRIPT_DIR/dracut-resume.conf" /etc/dracut.conf.d/resume.conf
  echo "Rebuilding initramfs..."
  sudo dracut -f --regenerate-all
fi

echo "Hibernate configured. Reboot required for changes to take effect."
