sudo dnf install -y neovim

if [ ! -e $HOME/.config/nvim ]; then
  git clone https://github.com/LazyVim/starter $HOME/.config/nvim
  rm -rf $HOME/.config/nvim/.git

  rm -rf $HOME/.config/nvim/lua/plugins
  ln -fsn $BASE_DIR/.config/nvim/lua/plugins $HOME/.config/nvim/lua/plugins
fi
