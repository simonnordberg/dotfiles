SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

sudo cp $SCRIPT_DIR/mullvad_tailscale.nft /etc/nftables/mullvad_tailscale.nft

sudo grep -qxF 'include "/etc/nftables/mullvad_tailscale.nft"' /etc/sysconfig/nftables.conf \
    || echo 'include "/etc/nftables/mullvad_tailscale.nft"' \
    | sudo tee -a /etc/sysconfig/nftables.conf  > /dev/null

# We need to enable nftables to support this configuration
sudo systemctl enable --now nftables