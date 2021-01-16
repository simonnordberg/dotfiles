export PATH=/opt/homebrew/bin:$HOME/bin:$HOME/Library/Python/3.7/bin:/usr/local/opt/python/libexec/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
export EDITOR='vim'

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

if command -v gpgconf > /dev/null; then
  export GPG_TTY="$(tty)"
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  gpgconf --launch gpg-agent
fi

if command -v jenv > /dev/null; then
    eval "$(jenv init -)"
fi
