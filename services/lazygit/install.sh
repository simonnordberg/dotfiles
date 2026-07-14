SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

sudo dnf copr enable atim/lazygit -y
sudo dnf install -y lazygit

mkdir -p $HOME/.config/lazygit
cp $SCRIPT_DIR/config.yml $HOME/.config/lazygit/config.yml
