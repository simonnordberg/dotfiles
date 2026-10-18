sudo dnf install -y aerc w3m

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

mkdir -p "$HOME/.config/aerc"
cp "$SCRIPT_DIR/accounts.conf" "$HOME/.config/aerc/accounts.conf"
cp "$SCRIPT_DIR/aerc.conf" "$HOME/.config/aerc/aerc.conf"
cp "$SCRIPT_DIR/binds.conf" "$HOME/.config/aerc/binds.conf"
chmod 600 "$HOME/.config/aerc/accounts.conf"
