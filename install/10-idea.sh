VERSION="ideaIC-2024.3.1.1"

if [ -d "/opt/$VERSION" ]; then
  echo "Intellij IDEA is already installed"
  return 0
fi

FILENAME="$VERSION.tar.gz"
DIR=$(mktemp -d)
URL="https://download-cdn.jetbrains.com/idea/$FILENAME"

curl -Lo $DIR/$FILENAME $URL
sudo tar -xf $DIR/$FILENAME -C /opt

cat <<EOF >$HOME/.local/share/applications/jetbrains-idea-ce.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=IntelliJ IDEA Community Edition
Icon=/opt/$VERSION/bin/idea.svg
Exec="/opt/$VERSION/bin/idea" %f
Comment=Capable and Ergonomic IDE for JVM
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-idea-ce
StartupNotify=true
EOF

