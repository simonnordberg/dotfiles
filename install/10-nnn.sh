sudo dnf install -y nnn

if [ -d $HOME/.config/nnn/plugins ]; then
  rm -rf $HOME/.config/nnn/plugins
fi

sh -c "$(curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs)"