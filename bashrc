# Git
source ~/.git-completion.bash
source ~/.git-prompt.sh

# Google SDK
source ~/code/lib/google-cloud-sdk/completion.bash.inc
source ~/code/lib/google-cloud-sdk/path.bash.inc

# Go
export GOPATH=$HOME/go

# Misc
export PATH=~/bin:$GOPATH/bin:/usr/local/bin:/usr/local/sbin:$HOME/.rvm/bin:/usr/local/heroku/bin:$PATH
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`

eval "$(rbenv init -)"

# Bash completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

# Python
export PIP_REQUIRE_VIRTUALENV=true
export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache
export SCRAPY_PYTHON_SHELL=ptpython

# Android
export ANDROID_HOME=/usr/local/opt/android-sdk

export EDITOR='emacsclient -t'
export ALTERNATE_EDITOR=vim

# 31-37
RED="\[\033[0;31m\]"
GREEN="\[\033[0;32m\]"
YELLOW="\[\033[0;33m\]"
BLUE="\[\033[34m\]"
MAGENTA="\[\033[0;35m\]"
CYAN="\[\033[0;36m\]"
WHITE="\[\033[0;37m\]"

GIT_PS1_SHOWDIRTYSTATE=true
export LS_OPTIONS='--color=auto'
export CLICOLOR='Yes'
export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD

# Lang
export LC_ALL=en_US.UTF-8
export LANG=en_us.UTF-8

export PS1=$WHITE"\u@\h"'$(
    if [[ $(__git_ps1) =~ \*\)$ ]]
    # a file has been modified but not added
    then echo "'$YELLOW'"$(__git_ps1 " (%s)")
    elif [[ $(__git_ps1) =~ \+\)$ ]]
    # a file has been added, but not commited
    then echo "'$MAGENTA'"$(__git_ps1 " (%s)")
    # the state is clean, changes are commited
    else echo "'$CYAN'"$(__git_ps1 " (%s)")
    fi)'$RED" \w"$GREEN": "

# AWS
export AWS_DEFAULT_PROFILE=eu-west-1

source ~/.bash.credentials
