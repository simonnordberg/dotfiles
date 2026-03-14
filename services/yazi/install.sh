SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Dependencies for previews
sudo dnf install -y file poppler-utils ffmpegthumbnailer fd-find ripgrep fzf zoxide imagemagick

# Install yazi via cargo
cargo install --locked yazi-fm yazi-cli

# Config
mkdir -p $HOME/.config/yazi
cp $SCRIPT_DIR/yazi.toml $HOME/.config/yazi/yazi.toml
cp $SCRIPT_DIR/keymap.toml $HOME/.config/yazi/keymap.toml
cp $SCRIPT_DIR/theme.toml $HOME/.config/yazi/theme.toml
