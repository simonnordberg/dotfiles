VERSION=3.12.4
PATH=$PATH:$HOME/.pyenv/bin

sudo dnf install -y zlib-ng-compat zlib-ng-compat-devel

[ -e $HOME/.pyenv ] && rm -rf $HOME/.pyenv
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

pyenv install --skip-existing $VERSION
