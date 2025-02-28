VERSION="0.0.87"

TARGET_DIR="/opt/discord-$VERSION"

if [ -d "$TARGET_DIR" ]; then
  echo "Discord is already installed"
  exit 0
fi

FILENAME="discord-$VERSION.tar.gz"
URL="https://discord.com/api/download?platform=linux&format=tar.gz"
DIR=$(mktemp -d)

sudo mkdir -p $TARGET_DIR
curl -Lo $DIR/$FILENAME $URL
sudo tar -xf $DIR/$FILENAME -C $TARGET_DIR --strip-components=1

mkdir -p $HOME/logs

cat <<EOF >$HOME/.local/share/applications/discord.desktop
[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
GenericName=Internet Messenger
Exec=sh -c "systemd-cat --identifier=discord $TARGET_DIR/Discord"
Icon=discord
Type=Application
Categories=Network;InstantMessaging;
Path=/usr/bin
EOF
