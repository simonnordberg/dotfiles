TARGET_DIR="/opt/cursor"
BIN_PATH="/usr/local/bin/cursor"
DESKTOP_FILE="$HOME/.local/share/applications/cursor.desktop"
URL="https://downloader.cursor.sh/linux/appImage/x64"

if [ -d "$TARGET_DIR" ]; then
  echo "Cursor is already installed at $TARGET_DIR"
  exit 0
fi

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT
cd "$TMP_DIR"

if ! curl -Lo ./cursor.appImage "$URL" --progress-bar; then
  echo "Error: Failed to download Cursor AppImage" >&2
  exit 1
fi

chmod +x ./cursor.appImage
if ! ./cursor.appImage --appimage-extract; then
  echo "Error: Failed to extract AppImage" >&2
  exit 1
fi

sudo mkdir -p "$TARGET_DIR"
sudo mv squashfs-root/* "$TARGET_DIR/"
sudo ln -sf "$TARGET_DIR/cursor" "$BIN_PATH"

cat <<EOF >"$DESKTOP_FILE"
[Desktop Entry]
Name=Cursor
Exec=$TARGET_DIR/cursor
Icon=$TARGET_DIR/resources/app/resources/linux/cursor.png
Type=Application
Categories=Development;IDE;
Terminal=false
EOF
