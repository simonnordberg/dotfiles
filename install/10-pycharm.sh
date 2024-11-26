PYCHARM_VERSION="pycharm-community-2024.3"

if [ -d "/opt/$PYCHARM_VERSION" ]; then
    echo "PyCharm is already installed"
    return 0
fi

FILENAME="$PYCHARM_VERSION.tar.gz"
DIR=$(mktemp -d)
URL="https://download-cdn.jetbrains.com/python/$FILENAME"

curl -Lo $DIR/$FILENAME $URL
sudo tar -xf $DIR/$FILENAME -C /opt

cat <<EOF > $HOME/.local/share/applications/jetbrains-pycharm-ce.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=PyCharm Community Edition
Icon=/opt/$PYCHARM_VERSION/bin/pycharm.svg
Exec="/opt/$PYCHARM_VERSION/bin/pycharm" %f
Comment=Python IDE for Professional Developers
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-pycharm-ce
StartupNotify=true
EOF