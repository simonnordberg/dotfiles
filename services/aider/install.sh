SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

sudo dnf install -y pipx python3-devel

if ! command -v aider &> /dev/null; then
    pipx install aider-chat
else
    echo "Aider is already installed"
fi

cp "$SCRIPT_DIR/aider.conf.yml" "$HOME/.aider.conf.yml"
