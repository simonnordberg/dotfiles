#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script is designed for macOS only!"
  exit 1
fi

if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -f "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

echo "Installing lazygit"
brew install lazygit

echo "Installing fonts"
brew install font-hack-nerd-font

echo "Installing ghostty"
brew install ghostty

echo "Installing Neovim and fzf..."
brew install neovim fzf

echo "Installing fish shell..."
brew install fish

echo "Setting fish as default shell..."
FISH_PATH=$(which fish)
if [[ "$SHELL" != "$FISH_PATH" ]]; then
  echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null
  chsh -s "$FISH_PATH"
fi

echo "Installing Starship prompt..."
if ! command -v starship &>/dev/null; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
  cp "$SCRIPT_DIR/services/shell/starship.toml" "$HOME/.config/starship.toml"
fi

echo "Installing ghostty config"
rm -rf $HOME/.config/ghostty
mkdir -p $HOME/.config/ghostty
cp $SCRIPT_DIR/services/ghostty/config $HOME/.config/ghostty/config

echo "Installing fish configuration..."
rm -rf $HOME/.config/fish
mkdir -p $HOME/.config/fish
cp -r "$SCRIPT_DIR/services/shell/fish/" "$HOME/.config/fish/"

echo "Installing Neovim"
brew install nvim luarocks tree-sitter-cli

echo "Installing Neovim configuration..."
rm -rf $HOME/.config/nvim
git clone https://github.com/LazyVim/starter $HOME/.config/nvim
cp -R $SCRIPT_DIR/services/neovim/config/* $HOME/.config/nvim/
rm -rf $HOME/.config/nvim/.git
echo "vim.opt.relativenumber = false" >>$HOME/.config/nvim/lua/config/options.lua

echo "Installing tmux..."
brew install tmux

echo "Installing tmuxinator..."
brew install tmuxinator

echo "Installation completed!"
