VERSION=3.12.4

[ ! -e $HOME/.pyenv ] && curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
pyenv install --skip-existing $VERSION
