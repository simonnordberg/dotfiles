VERSION=3.12.4

PATH=$PATH:$HOME/.pyenv/bin

[ -e $HOME/.pyenv ] && rm -rf $HOME/.pyenv
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

pyenv install --skip-existing $VERSION
