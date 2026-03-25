SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Dependencies for previews
sudo dnf install -y file poppler-utils ffmpegthumbnailer fd-find ripgrep fzf zoxide imagemagick

# Install/update yazi-build tool (fast if already current)
CARGO_OUTPUT=$(cargo install yazi-build 2>&1)
echo "$CARGO_OUTPUT"
UPDATED=$(echo "$CARGO_OUTPUT" | grep -c "Installing\|Compiling")

# Rebuild if new version detected or not built in the last 24 hours
STAMP="$HOME/.cache/yazi-build-stamp"
if [ "$UPDATED" -gt 0 ] || [ ! -f "$STAMP" ] || [ $(($(date +%s) - $(cat "$STAMP"))) -gt 86400 ]; then
  yazi-build
  mkdir -p "$(dirname "$STAMP")"
  date +%s > "$STAMP"
else
  echo "yazi: skipping build (last build <24h ago)"
fi

# Config
mkdir -p $HOME/.config/yazi
cp $SCRIPT_DIR/yazi.toml $HOME/.config/yazi/yazi.toml
cp $SCRIPT_DIR/keymap.toml $HOME/.config/yazi/keymap.toml
cp $SCRIPT_DIR/theme.toml $HOME/.config/yazi/theme.toml
