export PATH=$HOME/bin:/usr/local/opt/python/libexec/bin:/usr/local/bin:$PATH
export ZSH="/Users/simon/.oh-my-zsh"

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
export EDITOR='vim'

