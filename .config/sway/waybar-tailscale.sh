#!/bin/bash

format_status() {
  local state="$1"
  local class text tooltip

  case "$state" in
  "Running" | "Starting" | "Stopped")
    class="${state,,}"
    text="${state^}"
    tooltip="${state^}"
    ;;
  *)
    class="error"
    text="Error: $state"
    tooltip="Error: $state"
    ;;
  esac

  jq --unbuffered --compact-output -n \
    --arg text "$text" \
    --arg class "$class" \
    --arg alt "$class" \
    --arg tooltip "$tooltip" \
    '{text: $text, tooltip: $tooltip, class: $class, alt: $alt}'
}

get_tailscale_state() {
  json=$(tailscale status --json 2>/dev/null)
  state=$(echo "$json" | jq -r '.BackendState')
  online=$(echo "$json" | jq -r '.Self.Online') # Check difference between .Online and .Active

  if [[ "$state" == "Running" && "$online" == false ]]; then
    state="Starting"
  fi

  format_status "$state"
}

get_tailscale_state

journalctl -f -n 0 -u tailscaled.service | while IFS= read -r line; do
  # What else is needed to capture resume state?
  if echo "$line" | grep -q "Switching ipn state\|LinkChange\|netmap\|endpoints changed"; then
    get_tailscale_state
  fi
done
