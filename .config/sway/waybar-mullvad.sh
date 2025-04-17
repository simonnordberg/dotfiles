#!/usr/bin/env bash

set -euo pipefail

mullvad_connected() {
  mullvad status --json | jq -r '.state' | grep -q "^connected$" 2>/dev/null
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
  json=$(mullvad status --json)
  status=$(echo "$json" | jq -r '.state') || status="unknown"
  exitnode=$(echo "$json" | jq -r '.details.location.hostname') || exitnode="unknown"

  case $status in
  connected)
    format_status "Connected to $exitnode" "connected" "Connected to $exitnode"
    ;;
  connecting)
    format_status "Connecting to $exitnode..." "connecting" "Connecting to $exitnode..."
    ;;
  *)
    format_status "Not connected" "disconnected" "Not connected"
    ;;
  esac
  ;;
toggle)
  status=$(mullvad status --json | jq -r '.state')
  case $status in
  disconnected)
    mullvad connect
    ;;
  *)
    mullvad reconnect
    ;;
  esac
  ;;
*)
  echo "Usage: $0 status" >&2
  echo "       $0 toggle" >&2
  exit 1
  ;;
esac
