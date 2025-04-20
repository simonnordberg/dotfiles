#!/bin/bash

get_tailscale_state_info() {
    local to_state="$1"
    local -n state_ref="$2"
    local -n text_ref="$3"
    local -n tooltip_ref="$4"

    if [[ "$to_state" == "Running" ]]; then
        state_ref="connected"
        text_ref="Connected to Tailscale"
        tooltip_ref="Tailscale is running"
    elif [[ "$to_state" == "Starting" ]]; then
        state_ref="connecting"
        text_ref="Connecting to Tailscale"
        tooltip_ref="Tailscale is starting up"
    elif [[ "$to_state" == "Stopped" ]]; then
        state_ref="disconnected"
        text_ref="Disconnected from Tailscale"
        tooltip_ref="Tailscale is stopped"
    else
        state_ref="$to_state"
        text_ref="Tailscale state: $to_state"
        tooltip_ref="Tailscale changed from $from_state to $to_state"
    fi
}

output_json() {
    local text="$1"
    local state="$2"
    local tooltip="$3"
    jq --unbuffered --compact-output -n \
        --arg text "$text" \
        --arg class "$state" \
        --arg alt "$state" \
        --arg tooltip "$tooltip" \
        '{text: $text, class: $class, alt: $alt, tooltip: $tooltip}'
}

initial_state=$(tailscale status --json 2>/dev/null | jq -r '.BackendState')

echo "$initial_state"
get_tailscale_state_info "$initial_state" state text tooltip
output_json "$text" "$state" "$tooltip"

journalctl -f -u tailscaled | while IFS= read -r line; do
    if echo "$line" | grep -q "Switching ipn state"; then
        to_state=$(echo "$line" | sed -E 's/.*Switching ipn state ([^ ]+) -> ([^ ]+).*/\2/')

        get_tailscale_state_info "$to_state" state text tooltip
        output_json "$text" "$state" "$tooltip"
    fi
done
