VERSION=3.13.2

sudo dnf install -y \
  gcc make \
  zlib-ng-compat-devel \
  bzip2-devel \
  readline-devel \
  openssl-devel \
  sqlite-devel \
  libffi-devel \
  xz-devel \
  tk-devel

if [ ! -e "$HOME/.pyenv" ]; then
  curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

pyenv install --skip-existing $VERSION
