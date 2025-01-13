VERSION=3.12.4
PATH=$PATH:$HOME/.pyenv/bin

sudo dnf install -y \
  zlib-ng-compat \
  zlib-ng-compat-devel \
  sqlite-devel \
  libffi-devel

if [ ! -e $HOME/.pyenv ]; then
  curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
fi

pyenv install --skip-existing $VERSION
