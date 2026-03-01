sudo dnf install -y cups cups-browsed

sudo sed -i 's/^BrowseRemoteProtocols none/BrowseRemoteProtocols DNSSD/' /etc/cups/cups-browsed.conf

sudo firewall-cmd --permanent --add-service=mdns
sudo firewall-cmd --reload

sudo systemctl enable --now cups cups-browsed
