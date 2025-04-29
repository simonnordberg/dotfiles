desktop_file="$HOME/.local/share/applications/cursor.desktop"
bin_dir="$HOME/.local/bin"

versions=$(curl https://cursor.uuid.site/api/versions | jq -r '.versions[] | select(.isLatest == true)')
latest_version=$(echo "$versions" | jq -r '.version')
latest_url=$(echo "$versions" | jq -r '.linux.x64')
filename=$(basename "$latest_url")

mkdir -p $HOME/.local/bin
mkdir -p $HOME/.local/share/aplications

if [ -f "$bin_dir/$filename" ]; then
  echo "Cursor AppImage already exists: $bin_dir/$filename"
  exit 0
fi

if ! curl -Lo $bin_dir/$filename "$latest_url" --progress-bar; then
  echo "Error: Failed to download Cursor AppImage" >&2
  exit 1
fi

chmod +x $bin_dir/$filename

cat <<EOF >"$desktop_file"
[Desktop Entry]
Name=Cursor
Comment=The AI Code Editor.
GenericName=Text Editor
Exec=$bin_dir/$filename %F
Icon=co.anysphere.cursor
Type=Application
StartupNotify=false
StartupWMClass=Cursor
Categories=TextEditor;Development;IDE;
MimeType=application/x-cursor-workspace;
Actions=new-empty-window;
Keywords=cursor;
EOF
