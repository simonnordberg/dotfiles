sudo dnf install -y zsh

[[ -e $HOME/.oh-my-zsh/ ]] && rm -rf $HOME/.oh-my-zsh/
[[ -e $HOME/.zshrc ]] && rm -f $HOME/.zshrc

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/mroth/evalcache $HOME/.oh-my-zsh/custom/plugins/evalcache
git clone https://github.com/lukechilds/zsh-nvm $HOME/.oh-my-zsh/custom/plugins/zsh-nvm

ln -fsn $SCRIPT_DIR/.zshrc $HOME/.zshrc
ln -fsn $SCRIPT_DIR/.profile $HOME/.profile
ln -fsn $SCRIPT_DIR/.zprofile $HOME/.zprofile