SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

sudo cp $SCRIPT_DIR/reset-usb-after-resume.service /etc/systemd/system/reset-usb-after-resume.service
sudo systemctl daemon-reload
sudo systemctl enable reset-usb-after-resume.service

sudo cp $SCRIPT_DIR/wakeup /usr/lib/systemd/system-sleep/wakeup
sudo chmod +x /usr/lib/systemd/system-sleep/wakeup