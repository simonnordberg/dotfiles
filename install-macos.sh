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

echo "Installing zsh configuration..."
cp "$SCRIPT_DIR/services/shell/zsh/.zshrc" "$HOME/.zshrc"

echo "Installing Starship prompt..."
if ! command -v starship &>/dev/null; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi
mkdir -p "$HOME/.config"
cp "$SCRIPT_DIR/services/shell/starship.toml" "$HOME/.config/starship.toml"

echo "Installing ghostty config"
mkdir -p $HOME/.config/ghostty
cp $SCRIPT_DIR/services/ghostty/config $HOME/.config/ghostty/config

echo "Installing Neovim configuration..."
if [ ! -e $HOME/.config/nvim ]; then
  git clone https://github.com/LazyVim/starter $HOME/.config/nvim
  rm -rf $HOME/.config/nvim/.git
fi
rsync -r --delete $SCRIPT_DIR/services/neovim/config/lua/plugins/ $HOME/.config/nvim/lua/plugins/

echo "Installing tmux..."
brew install tmux

echo "Installing tmuxinator..."
brew install tmuxinator

echo "Installation completed!"
