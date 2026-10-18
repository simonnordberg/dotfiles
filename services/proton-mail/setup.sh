#!/usr/bin/env bash
#
# Store the Proton Bridge password in GNOME Keyring.
#
# Run this once per machine after installing Proton Bridge and logging in.
# The password is machine-specific (each bridge installation generates its own).
# himalaya and aerc read it from the keyring via secret-tool at runtime.
#
# Prerequisites:
#   1. Proton Bridge installed and logged in (services/proton-mail/install.sh)
#   2. Get your bridge password:
#        flatpak run ch.protonmail.protonmail-bridge --cli
#        >>> info 0
#
# Usage:
#   bash services/proton-mail/setup.sh
#
set -euo pipefail

ACCOUNT="simon@simonnordberg.com"

if secret-tool lookup service protonmail-bridge account "$ACCOUNT" > /dev/null 2>&1; then
  echo "Proton Bridge password already stored in keyring."
  read -rp "Overwrite? [y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]] || exit 0
fi

echo "Open Proton Bridge CLI to get your password:"
echo "  flatpak run ch.protonmail.protonmail-bridge --cli"
echo "  >>> info 0"
echo ""
echo "Enter the bridge password:"
secret-tool store --label='Proton Bridge' service protonmail-bridge account "$ACCOUNT"
echo "Stored in keyring."
