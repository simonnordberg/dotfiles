# Install fingerprint reader support
sudo dnf install -y fprintd fprintd-pam

# Enable fingerprint auth in PAM via authselect
sudo authselect enable-feature with-fingerprint 2>/dev/null || true

# Enroll fingerprints if a reader is present and none are enrolled yet
if fprintd-list "$(whoami)" &>/dev/null; then
  if fprintd-list "$(whoami)" 2>&1 | grep -q "no fingers enrolled"; then
    echo ""
    echo "Fingerprint reader detected. Starting enrollment..."
    echo "You will be asked to scan each finger multiple times."
    echo ""

    for finger in right-index-finger right-middle-finger left-index-finger; do
      echo "--- Enrolling $finger (press Ctrl+C to skip) ---"
      fprintd-enroll -f "$finger" || true
    done

    echo ""
    echo "Enrolled fingers:"
    fprintd-list "$(whoami)"
  else
    echo "Fingerprints already enrolled, skipping."
  fi
else
  echo "No fingerprint reader detected, skipping enrollment."
fi
