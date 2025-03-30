SCRIPT_PATH="$HOME/.local/bin/clean-downloads.sh"

ln -fsn $BASE_DIR/.local/bin/clean-downloads.sh $SCRIPT_PATH

CRON_JOB="18 * * * * $SCRIPT_PATH"
if crontab -l 2>/dev/null | grep -q "$SCRIPT_PATH"; then
    echo -e "Cron job for downloads cleaner already exists. Skipping..."
else
    echo "Adding cron job to run hourly..."
    (
        crontab -l 2>/dev/null
        echo "$CRON_JOB"
    ) | crontab -
fi
