SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

sudo dnf install -y tmux

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm 2>/dev/null || true

cp $SCRIPT_DIR/tmux.conf $HOME/.tmux.conf
