VERSION="pycharm-community-2024.3"

if [ -d "/opt/$VERSION" ]; then
  echo "PyCharm is already installed"
  exit 0
fi

FILENAME="$VERSION.tar.gz"
DIR=$(mktemp -d)
URL="https://download-cdn.jetbrains.com/python/$FILENAME"

curl -Lo $DIR/$FILENAME $URL
sudo mkdir -p /opt/$VERSION
sudo tar -xf $DIR/$FILENAME -C /opt/$VERSION --strip-components=1

cat <<EOF >$HOME/.local/share/applications/jetbrains-pycharm-ce.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm Community Edition
Icon=/opt/$VERSION/bin/pycharm.svg
Exec="/opt/$VERSION/bin/pycharm" %f
Comment=Python IDE for Professional Developers
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-pycharm-ce
StartupNotify=true
EOF
