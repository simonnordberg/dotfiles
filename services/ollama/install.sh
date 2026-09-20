SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

if ! command -v ollama &> /dev/null; then
    curl -fsSL https://ollama.com/install.sh | sh
else
    echo "Ollama is already installed"
fi

# The installer enables and starts a system-wide unit; disable it in favor of
# the user unit below so ollama only runs in-session (matches OLLAMA_HOST config).
sudo systemctl disable --now ollama

mkdir -p "$HOME/.config/systemd/user"
cp "$SCRIPT_DIR/ollama.service" "$HOME/.config/systemd/user/ollama.service"
systemctl --user daemon-reload

cp "$SCRIPT_DIR/pull-models" "$HOME/.local/bin/ollama-pull-models"
chmod +x "$HOME/.local/bin/ollama-pull-models"
