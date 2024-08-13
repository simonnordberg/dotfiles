CONFIG=$HOME/.config/nvim

sudo dnf install -y neovim

if [[ ! -e $CONFIG ]]; then
  git clone https://github.com/LazyVim/starter $HOME/.config/nvim
  rm -rf $HOME/.config/nvim/.git
fi

ln -fsn $SCRIPT_DIR/.config/nvim/lua/plugins/theme.lua $HOME/.config/nvim/lua/plugins/theme.lua
