URL=https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz
DIR=$(mktemp -d)

curl -Lo $DIR/zellij.tar.gz $URL
tar -xf $DIR/zellij.tar.gz -C $DIR
sudo install $DIR/zellij /usr/local/bin

mkdir -p $HOME/.config
ln -fsn $BASE_DIR/.config/zellij $HOME/.config/zellij
