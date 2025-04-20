#!/bin/bash

output_mullvad_state() {
    local state="$1"
    local hostname="$2"
    local class text tooltip

    case "$state" in
    "connected" | "connecting")
        class="$state"
        text="${state^} to $hostname"
        tooltip="$text"
        ;;
    "disconnected" | "disconnecting")
        class="$state"
        text="${state^}"
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

# get initial state
read -r state hostname < <(mullvad status --json 2>/dev/null | jq -r '[.state, (.details.location.hostname // empty)] | @tsv')
output_mullvad_state "$state" "$hostname"

# Monitor for state changes
journalctl -f -n 0 -u mullvad-daemon.service | while IFS= read -r line; do
    if echo "$line" | grep -q "New tunnel state:"; then
        state=$(echo "$line" | grep -o "New tunnel state: \(Disconnecting\|Connecting\|Connected\|Disconnected\)" | cut -d ' ' -f4 | tr '[:upper:]' '[:lower:]')
        hostname=$(echo "$line" | grep -o 'hostname: Some("[^"]*")' | sed -E 's/hostname: Some\("([^"]*)"\)/\1/' || echo "")
        output_mullvad_state "$state" "$hostname"
    fi
done
