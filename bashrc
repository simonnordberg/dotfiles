SCRIPT_DIR="$(cd "$(dirname $(realpath "${BASH_SOURCE[0]}"))" && pwd -P)"

on_osx_init() {
    export JAVA_HOME=`/usr/libexec/java_home -v 1.8`
    export ANDROID_HOME=/usr/local/opt/android-sdk
    eval "$(rbenv init -)"

    # Bash completion
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
    	. $(brew --prefix)/etc/bash_completion
    fi
}

on_linux_init() {
    export CUDA_HOME=/usr/local/cuda-8.0
    export LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
    export PATH="$HOME/.local/bin/:$PATH"
    export PATH=/usr/local/cuda-8.0/bin${PATH:+:${PATH}}
}

if [ -f $SCRIPT_DIR/git-completion.bash ]; then
    source $SCRIPT_DIR/git-completion.bash
fi

if [ -f $SCRIPT_DIR/git-prompt.sh ]; then
    source $SCRIPT_DIR/git-prompt.sh
fi

if [ -f ~/.bash.credentials ]; then
    source ~/.bash.credentials
fi

if [ -f ~/.bash.local ]; then
    source ~/.bash.local
fi

if [ -d ~/code/lib/google-cloud-sdk ]; then
    source ~/code/lib/google-cloud-sdk/completion.bash.inc
    source ~/code/lib/google-cloud-sdk/path.bash.inc
fi

export GOPATH=$HOME/go
export AWS_DEFAULT_PROFILE=eu-west-1
export PATH=~/bin:$GOPATH/bin:/usr/local/bin:/usr/local/sbin:$HOME/.rvm/bin:/usr/local/heroku/bin:$PATH
export PIP_REQUIRE_VIRTUALENV=true
export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache
export SCRAPY_PYTHON_SHELL=ptpython
export EDITOR='nvim'
export ALTERNATE_EDITOR=vim

# 31-37
RED="\[\033[0;31m\]"
GREEN="\[\033[0;32m\]"
YELLOW="\[\033[0;33m\]"
BLUE="\[\033[34m\]"
MAGENTA="\[\033[0;35m\]"
CYAN="\[\033[0;36m\]"
WHITE="\[\033[0;37m\]"

export GIT_PS1_SHOWDIRTYSTATE=true
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

case "$OSTYPE" in
    darwin*)  on_osx_init ;;
    linux*)   on_linux_init ;;
    *)        ;;
esac

generate_password() {
    length=$((${1:-23} + 1))
    openssl rand -base64 32 | sed 's/[^[:alnum:]]//g' | colrm $length
}

HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s checkwinsize
shopt -s histappend

if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Start or re-use a gpg-agent.
gpgconf --launch gpg-agent
export SSH_AUTH_SOCK=$HOME/.gnupg/S.gpg-agent.ssh
