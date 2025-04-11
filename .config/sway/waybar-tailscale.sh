#!/usr/bin/env bash

# Remember to set tailscale operator to not require root, i.e.
#   sudo tailscale set --operator=$USER

set -euo pipefail

tailscale_running() {
  curl -s https://am.i.mullvad.net/json 2>/dev/null | jq '.mullvad_exit_ip' | grep -q "true"
}

format_status() {
  local text="$1"
  local class="$2"
  local tooltip="$3"
  jq -c -n \
    --arg text "$text" \
    --arg class "$class" \
    --arg tooltip "$tooltip" \
    '{text: $text, class: $class, alt: $class, tooltip: $tooltip}'
}

# Check if an argument was provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 [status|toggle]" >&2
  exit 1
fi

case $1 in
status)
  if tailscale_running; then
    exitnode=$(curl -s https://am.i.mullvad.net/json 2>/dev/null | jq -r '.mullvad_exit_ip_hostname')
    format_status "Connected to $exitnode" "connected" "Connected to $exitnode"
  else
    format_status "Not connected" "disconnected" "Not connected"
  fi
  ;;
toggle)
  if tailscale_running; then
    tailscale down
  else
    tailscale up --exit-node-allow-lan-access --exit-node $(tailscale exit-node suggest | head -n 1 | awk '{print $NF}')
  fi
  ;;
*)
  echo "Usage: $0 status" >&2
  echo "       $0 toggle" >&2
  exit 1
  ;;
esac
