sudo dnf install -y openssh

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

mkdir -p $HOME/.ssh 
cp $SCRIPT_DIR/config $HOME/.ssh/config
