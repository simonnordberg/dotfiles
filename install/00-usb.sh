sudo cp $BASE_DIR/root/etc/systemd/system/reset-usb-after-resume.service /etc/systemd/system/reset-usb-after-resume.service
sudo systemctl daemon-reload
sudo systemctl enable reset-usb-after-resume.service
