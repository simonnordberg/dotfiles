VERSION="ideaIU-2025.1"

if [ -d "/opt/$VERSION" ]; then
  echo "Intellij IDEA is already installed"
  exit 0
fi

FILENAME="$VERSION.tar.gz"
DIR=$(mktemp -d)
URL="https://download-cdn.jetbrains.com/idea/$FILENAME"

curl -Lo $DIR/$FILENAME $URL
sudo mkdir -p /opt/$VERSION
sudo tar -xf $DIR/$FILENAME -C /opt/$VERSION --strip-components=1

mkdir -p "$HOME/.local/share/applications"
cat <<'EOF' >"$HOME/.local/share/applications/jetbrains-idea.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=IntelliJ IDEA Ultimate Edition
Icon=/opt/$VERSION/bin/idea.svg
Exec="/opt/$VERSION/bin/idea" %f
Comment=Capable and Ergonomic IDE for JVM
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-idea
StartupNotify=true
EOF
