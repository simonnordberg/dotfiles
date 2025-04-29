SERVICE_DIR="$(dirname "$(readlink -f "$0")")"

cp $SERVICE_DIR/fp $HOME/.local/bin/fp
cp $SERVICE_DIR/term $HOME/.local/bin/term

