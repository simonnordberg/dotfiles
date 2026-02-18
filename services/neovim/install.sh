SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

sudo dnf install -y neovim fzf

if [ ! -e $HOME/.config/nvim ]; then
  git clone https://github.com/LazyVim/starter $HOME/.config/nvim
  rm -rf $HOME/.config/nvim/.git
fi

rm -rf $HOME/.config/nvim/lua/plugins
rsync -r --delete $SCRIPT_DIR/config/lua/plugins/ $HOME/.config/nvim/lua/plugins/
