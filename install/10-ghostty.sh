# Based on https://ghostty.org/docs/install/build

VERSION=v1.1.0

ln -fsn $BASE_DIR/.config/ghostty $HOME/.config/ghostty

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
git checkout $VERSION

# Install for local user
zig build -p $HOME/.local -Doptimize=ReleaseFast
