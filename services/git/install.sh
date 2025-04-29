sudo dnf install -y git

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

cp $SCRIPT_DIR/config $HOME/.gitconfig
