SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

sudo dnf install -y zsh fzf
sudo chsh -s $(which zsh) $USER

curl -sS https://starship.rs/install.sh | sh -s -- -y

cp $SCRIPT_DIR/zsh/.zshrc $HOME/.zshrc

mkdir -p $HOME/.zsh/completions
mkdir -p $HOME/.config
cp $SCRIPT_DIR/starship.toml $HOME/.config/starship.toml
