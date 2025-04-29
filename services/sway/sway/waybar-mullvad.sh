#!/bin/bash

format_status() {
    local state="$1"
    local message="$2"
    local class text tooltip

    case "$state" in
    "connected" | "connecting")
        class="$state"
        text="${state^} to $message"
        tooltip="$text"
        ;;
    "disconnected" | "disconnecting")
        class="$state"
        text="${state^}"
        tooltip="${state^}"
        ;;
    *)
        class="error"
        text="Error: $message"
        tooltip="Error: $message"
        ;;
    esac

    jq --unbuffered --compact-output -n \
        --arg text "$text" \
        --arg class "$class" \
        --arg alt "$class" \
        --arg tooltip "$tooltip" \
        '{text: $text, tooltip: $tooltip, class: $class, alt: $alt}'
}

get_mullvad_state() {
    json=$(mullvad status --json 2>/dev/null)
    state=$(echo "$json" | jq -r '.state')
    local message

    case "$state" in
    "connected" | "connecting")
        message=$(echo "$json" | jq -r '(.details.location.hostname // empty)')
        ;;
    "error")
        message=$(echo "$json" | jq -r '(.details.cause.reason // empty)')
        if [[ "$message" == "is_offline" ]]; then
            state="connecting"
            message=""
        fi
        ;;
    *)
        message=""
        ;;
    esac

    format_status "$state" "$message"
}

get_mullvad_state

journalctl -f -n 0 -u mullvad-daemon.service | while IFS= read -r line; do
    if echo "$line" | grep -q "New tunnel state:"; then
        get_mullvad_state
    fi
done
