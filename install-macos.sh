#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "This script is designed for macOS only!"
    exit 1
fi

if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

echo "Installing Neovim and fzf..."
brew install neovim fzf

echo "Installing fish shell..."
brew install fish

echo "Setting fish as default shell..."
FISH_PATH=$(which fish)
if [[ "$SHELL" != "$FISH_PATH" ]]; then
    echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
    chsh -s "$FISH_PATH"
fi

echo "Installing Starship prompt..."
curl -sS https://starship.rs/install.sh | sh -s -- -y

mkdir -p "$HOME/.config/fish"
mkdir -p "$HOME/.config/nvim"

echo "Installing fish configuration..."
rm -rf "$HOME/.config/fish"
cp -r "$SCRIPT_DIR/services/shell/fish/" "$HOME/.config/fish/"

cp "$SCRIPT_DIR/services/shell/starship.toml" "$HOME/.config/starship.toml"

echo "Installing Neovim configuration..."
if [ ! -e "$HOME/.config/nvim/init.lua" ]; then
    git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
    rm -rf "$HOME/.config/nvim/.git"
fi

if [ -d "$SCRIPT_DIR/services/neovim/lua/plugins" ]; then
    rm -rf "$HOME/.config/nvim/lua/plugins"
    cp -r "$SCRIPT_DIR/services/neovim/lua/plugins/" "$HOME/.config/nvim/lua/plugins/"
fi

echo "Installing tmux..."
brew install tmux

echo "Installing tmuxinator..."
brew install tmuxinator

echo "Installation completed!" 
