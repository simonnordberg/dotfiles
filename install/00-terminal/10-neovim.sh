CONFIG=$HOME/.config/nvim

sudo dnf install -y neovim

if [[ ! -e $CONFIG ]]; then
  git clone https://github.com/LazyVim/starter $HOME/.config/nvim
fi
