export PATH=$HOME/bin:/usr/local/opt/python/libexec/bin:/usr/local/bin:$PATH
export ZSH="/Users/simon.nordberg/.oh-my-zsh"

ZSH_THEME="blinks"
CASE_SENSITIVE="true"
HIST_STAMPS="yyyy-mm-dd"
ENABLE_CORRECTION="true"

plugins=(
    git
    osx
    ruby
    dotenv
)

fpath=(/usr/local/share/zsh-completions $fpath)

source $ZSH/oh-my-zsh.sh
source $HOME/.bash.credentials
source $HOME/.bash.local
export EDITOR='vim'

source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
