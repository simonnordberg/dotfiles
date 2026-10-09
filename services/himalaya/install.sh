sudo dnf install -y rust cargo
cargo install himalaya --locked

mkdir -p "$HOME/.config/himalaya"
cp config.toml "$HOME/.config/himalaya/config.toml"
