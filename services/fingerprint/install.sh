sudo dnf install -y fprintd fprintd-pam

# Disable fingerprint auth; use password everywhere
sudo authselect disable-feature with-fingerprint 2>/dev/null || true
