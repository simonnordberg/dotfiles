#!/bin/bash

output_tailscale_state() {
    local state="$1"
    local class text tooltip

    case "$state" in
    "Running" | "Starting" | "Stopped")
        class="${state,,}"
        text="Tailscale is ${state,,}"
        tooltip="$text"
        ;;
    *)
        class="unknown"
        text="Unknown state: $state"
        tooltip="$text"
        ;;
    esac

    jq --unbuffered --compact-output -n \
        --arg text "$text" \
        --arg class "$class" \
        --arg alt "$class" \
        --arg tooltip "$tooltip" \
        '{text: $text, tooltip: $tooltip, class: $class, alt: $alt}'
}

# Get initial state and output
state=$(tailscale status --json 2>/dev/null | jq -r '.BackendState')
output_tailscale_state "$state"

# Monitor for state changes
journalctl -f -n 0 -u tailscaled.service | while IFS= read -r line; do
    if echo "$line" | grep -q "Switching ipn state"; then
        state=$(echo "$line" | sed -E 's/.*Switching ipn state ([^ ]+) -> ([^ ]+).*/\2/')
        output_tailscale_state "$state"
    fi
done
