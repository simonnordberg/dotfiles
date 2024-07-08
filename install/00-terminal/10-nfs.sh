PARTIAL_FSTAB="$SCRIPT_DIR/root/etc/fstab.partial"
START_MARKER="# Begin Custom Mounts"
END_MARKER="# End Custom Mounts"

sudo dnf install -y nfs-utils
sudo cp /etc/fstab "/etc/fstab.backup.$(date +%Y%m%d%H%M%S)"
sudo sed -i "/$START_MARKER/,/$END_MARKER/d" /etc/fstab
{
  echo "$START_MARKER"
  cat "$PARTIAL_FSTAB"
  echo "$END_MARKER"
} | sudo tee -a /etc/fstab > /dev/null