export PATH=/opt/homebrew/bin:$HOME/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
export EDITOR='vim'

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

ZSH_THEME="blinks"
CASE_SENSITIVE="true"
HIST_STAMPS="yyyy-mm-dd"
ENABLE_CORRECTION="false"

plugins=(
    git
    osx
    ruby
    dotenv
)

fpath=(/usr/local/share/zsh-completions $fpath)
source $ZSH/oh-my-zsh.sh

if [ -f $(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc ]; then
    source $(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc 
fi 

if command -v gpgconf 1> /dev/null; then
  export GPG_TTY="$(tty)"
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  gpgconf --launch gpg-agent
fi

if command -v brew 1> /dev/null; then
    eval $(brew shellenv)
fi

if command -v jenv 1> /dev/null; then
    eval "$(jenv init -)"
fi

if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

if command -v rbenv 1>/dev/null 2>&1; then
    eval "$(rbenv init -)"
    export PATH="$HOME/.local/share/gem/ruby/3.0.0/bin:$PATH"
fi
