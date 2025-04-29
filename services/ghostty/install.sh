# Based on https://ghostty.org/docs/install/build

VERSION=v1.1.3

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

rm -rf $HOME/.config/ghostty
mkdir -p $HOME/.config/ghostty
cp $SCRIPT_DIR/config $HOME/.config/ghostty/config

sudo dnf install -y \
  gtk4-devel \
  zig \
  libadwaita-devel

mkdir -p $HOME/code/github

if [ ! -d $HOME/code/github/ghostty ]; then
  git clone https://github.com/ghostty-org/ghostty $HOME/code/github/ghostty
fi

cd $HOME/code/github/ghostty

git fetch
if [ "$(git rev-parse HEAD)" != "$(git rev-parse $VERSION)" ]; then
  git checkout $VERSION
fi

zig build -p $HOME/.local -Doptimize=ReleaseFast
