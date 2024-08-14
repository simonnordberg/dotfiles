sudo dnf install -y openssh

mkdir -p $HOME/.ssh
ln -fsn $BASE_DIR/.ssh/config $HOME/.ssh/config
