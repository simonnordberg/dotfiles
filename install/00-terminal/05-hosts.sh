PARTIAL="$SCRIPT_DIR/root/etc/hosts.partial"
START_MARKER="# start-hosts"
END_MARKER="# end-hosts"

sudo cp /etc/hosts "/etc/hosts.backup.$(date +%Y%m%d%H%M%S)"
sudo sed -i "/$START_MARKER/,/$END_MARKER/d" /etc/hosts
{
  echo "$START_MARKER"
  cat "$PARTIAL"
  echo "$END_MARKER"
} | sudo tee -a /etc/hosts >/dev/null
