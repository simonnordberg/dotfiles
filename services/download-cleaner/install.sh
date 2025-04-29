#!/usr/bin/env bash

export SERVICE_DIR="$(dirname "$(readlink -f "$0")")"

cp $SERVICE_DIR/clean-downloads $HOME/.local/bin/clean-downloads

CRON_JOB="18 * * * * $HOME/.local/bin/clean-downloads"
if crontab -l 2>/dev/null | grep -q "$HOME/.local/bin/clean-downloads"; then
    echo -e "Cron job for downloads cleaner already exists. Skipping..."
else
    echo "Adding cron job to run hourly..."
    (
        crontab -l 2>/dev/null
        echo "$CRON_JOB"
    ) | crontab -
fi
