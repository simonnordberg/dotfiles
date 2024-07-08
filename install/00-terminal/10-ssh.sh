sudo dnf install -y openssh

mkdir -p $HOME/.ssh
ln -fsn $SCRIPT_DIR/.ssh/config $HOME/.ssh/config
