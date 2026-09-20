SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

sudo dnf install -y podman

podman pull docker.io/searxng/searxng:latest

mkdir -p "$HOME/.config/searxng"
cp "$SCRIPT_DIR/settings.yml" "$HOME/.config/searxng/settings.yml"

mkdir -p "$HOME/.config/systemd/user"
cp "$SCRIPT_DIR/searxng.service" "$HOME/.config/systemd/user/searxng.service"
systemctl --user daemon-reload
