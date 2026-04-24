if ! command -v tailscale &> /dev/null; then
    curl -fsSL https://tailscale.com/install.sh | sh
else
    echo "Tailscale is already installed"
fi

# Allow local network access when using an exit node (e.g. Mullvad VPN)
sudo tailscale set --exit-node-allow-lan-access

mkdir -p "$HOME/.zsh/completions"
tailscale completion zsh > "$HOME/.zsh/completions/_tailscale"
