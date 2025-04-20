#!/bin/bash

while IFS= read -r line; do
    # Check if the line contains "New tunnel state:"
    if echo "$line" | grep -q "New tunnel state:"; then
        state=$(echo "$line" | sed -E 's/.*New tunnel state: ([^{]+).*/\1/' | tr -d ' ')
        base_state=$(echo "$state" | tr '[:upper:]' '[:lower:]')

        hostname=""
        if echo "$line" | grep -q "hostname: Some"; then
            hostname=$(echo "$line" | sed -E 's/.*hostname: Some\("([^"]+)"\).*/\1/')
        fi

        if [[ $base_state == "disconnecting" ]]; then
            text="Disconnecting"
            tooltip="Disconnecting"
        elif [[ $base_state == "disconnected" ]]; then
            text="Disconnected"
            tooltip="Disconnected"
        elif [[ $base_state == "connecting" ]] && [[ -n "$hostname" ]]; then
            text="Connecting to $hostname"
            tooltip="Connecting to $hostname"
        elif [[ $base_state == "connected" ]] && [[ -n "$hostname" ]]; then
            text="Connected to $hostname"
            tooltip="Connected to $hostname"
        else
            text="State: $base_state"
            tooltip="State: $base_state"
        fi

        # Use jq to format the JSON output properly
        jq --unbuffered --compact-output -n --arg text "$text" \
            --arg class "$base_state" \
            --arg alt "$base_state" \
            --arg tooltip "$tooltip" \
            '{text: $text, class: $class, alt: $alt, tooltip: $tooltip}'
    fi
done
