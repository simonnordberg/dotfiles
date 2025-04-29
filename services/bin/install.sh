SERVICE_DIR="$(dirname "$(readlink -f "$0")")"

rm -f $HOME/.local/bin/fp
rm -f $HOME/.local/bin/term

cp $SERVICE_DIR/fp $HOME/.local/bin/fp
cp $SERVICE_DIR/term $HOME/.local/bin/term

