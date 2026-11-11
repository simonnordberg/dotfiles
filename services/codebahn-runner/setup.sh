#!/usr/bin/env bash
#
# Register this machine as a Codebahn runner.
#
# Run this once after install.sh. The credentials are machine-specific
# (each runner needs its own UUID and token from codebahn.net).
#
# Prerequisites:
#   1. codebahn-runner installed (services/codebahn-runner/install.sh)
#   2. Get runner credentials:
#        codebahn.net > Settings > Actions > Runners > Create new runner
#
# Usage:
#   bash services/codebahn-runner/setup.sh
#
set -euo pipefail

APP_DIR=/srv/apps/forgejo-runner
CONFIG="$APP_DIR/config.yml"

if [ -f "$CONFIG" ]; then
  echo "Codebahn runner already configured."
  read -rp "Overwrite? [y/N] " answer
  [[ "$answer" =~ ^[Yy]$ ]] || exit 0
fi

echo "Enter runner credentials from codebahn.net Settings > Actions > Runners:"
echo ""
read -rp "  UUID:  " RUNNER_UUID
read -rp "  Token: " RUNNER_TOKEN

if [ -z "$RUNNER_UUID" ] || [ -z "$RUNNER_TOKEN" ]; then
  echo "ERROR: UUID and token are required."
  exit 1
fi

sudo tee "$CONFIG" >/dev/null <<TEMPLATE
server:
  connections:
    codebahn:
      url: https://codebahn.net/
      uuid: ${RUNNER_UUID}
      token: ${RUNNER_TOKEN}

runner:
  capacity: 3
  timeout: 3h
  labels:
    - self-hosted:docker://rg.fr-par.scw.cloud/codebahn-runner/ubuntu:24.04
    - docker:docker://rg.fr-par.scw.cloud/codebahn-runner/ubuntu:24.04

container:
  docker_host: unix:///var/run/docker.sock
  network: "host"
  valid_volumes:
    - /var/run/docker.sock
TEMPLATE

sudo chown forgejo-runner:forgejo-runner "$CONFIG"
sudo chmod 0600 "$CONFIG"

sudo systemctl restart forgejo-runner.service
echo "Codebahn runner started. Check: systemctl status forgejo-runner"
