SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

sudo dnf install -y podman

podman pull ghcr.io/open-webui/open-webui:main

mkdir -p "$HOME/.config/systemd/user"
cp "$SCRIPT_DIR/open-webui.service" "$HOME/.config/systemd/user/open-webui.service"
systemctl --user daemon-reload
