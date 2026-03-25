SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Dependencies for previews
sudo dnf install -y file poppler-utils ffmpegthumbnailer fd-find ripgrep fzf zoxide imagemagick

# Install/update yazi-build tool (fast if already current)
CARGO_OUTPUT=$(cargo install yazi-build 2>&1)
echo "$CARGO_OUTPUT"
UPDATED=$(echo "$CARGO_OUTPUT" | grep -c "Installing\|Compiling")

# Rebuild only if a new version was installed
if [ "$UPDATED" -gt 0 ]; then
  yazi-build
else
  echo "yazi: already up to date"
fi

# Config
mkdir -p $HOME/.config/yazi
cp $SCRIPT_DIR/yazi.toml $HOME/.config/yazi/yazi.toml
cp $SCRIPT_DIR/keymap.toml $HOME/.config/yazi/keymap.toml
cp $SCRIPT_DIR/theme.toml $HOME/.config/yazi/theme.toml
