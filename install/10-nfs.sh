mkdir -p /mnt/home
mkdir -p /mnt/media

PARTIAL="$BASE_DIR/root/etc/fstab.partial"
START_MARKER="# start-fstab"
END_MARKER="# end-fstab"

sudo dnf install -y nfs-utils
sudo cp /etc/fstab "/etc/fstab.backup.$(date +%Y%m%d%H%M%S)"
sudo sed -i "/$START_MARKER/,/$END_MARKER/d" /etc/fstab
{
  echo "$START_MARKER"
  cat "$PARTIAL"
  echo "$END_MARKER"
} | sudo tee -a /etc/fstab >/dev/null

sudo systemctl daemon-reload
sudo mount -a
