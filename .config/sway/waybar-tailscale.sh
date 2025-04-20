#!/bin/bash

format_status() {
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

get_tailscale_state() {
    read -r state < <(tailscale status --json 2>/dev/null | jq -r '.BackendState')
    format_status "$state"
}

get_tailscale_state

journalctl -f -n 0 -u tailscaled.service | while IFS= read -r line; do
    if echo "$line" | grep -q "Switching ipn state"; then
        get_tailscale_state
    fi
done
