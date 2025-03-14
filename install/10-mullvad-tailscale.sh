sudo cp $BASE_DIR/root/etc/nftables/mullvad_tailscale.nft /etc/nftables/mullvad_tailscale.nft

sudo grep -qxF 'include "/etc/nftables/mullvad_tailscale.nft"' /etc/sysconfig/nftables.conf \
    || echo 'include "/etc/nftables/mullvad_tailscale.nft"' \
    | sudo tee -a /etc/sysconfig/nftables.conf  > /dev/null
