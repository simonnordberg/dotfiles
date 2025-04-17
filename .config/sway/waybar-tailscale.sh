#!/usr/bin/env bash

# Remember to set tailscale operator to not require root, i.e.
#   sudo tailscale set --operator=$USER

set -euo pipefail

tailscale_running() {
  tailscale status >/dev/null 2>&1
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
    format_status "Running" "running" "Running"
  else
    format_status "Stopped" "stopped" "Stopped"
  fi
  ;;
toggle)
  if tailscale_running; then
    tailscale down
  else
    tailscale up
  fi
  ;;
*)
  echo "Usage: $0 status" >&2
  echo "       $0 toggle" >&2
  exit 1
  ;;
esac
