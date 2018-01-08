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
	:		
}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source $DIR/git-completion.bash
source $DIR/git-prompt.sh

if [ -e ~/.bash.credentials ]; then
	source ~/.bash.credentials
fi

if [ -e ~/code/lib/google-cloud-sdk ]; then
    source ~/code/lib/google-cloud-sdk/completion.bash.inc
    source ~/code/lib/google-cloud-sdk/path.bash.inc
fi

# Go
export GOPATH=$HOME/go
export AWS_DEFAULT_PROFILE=eu-west-1
export PATH=~/bin:$GOPATH/bin:/usr/local/bin:/usr/local/sbin:$HOME/.rvm/bin:/usr/local/heroku/bin:$PATH
export PIP_REQUIRE_VIRTUALENV=true
export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache
export SCRAPY_PYTHON_SHELL=ptpython
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
  	darwin*)	on_osx_init ;; 
  	linux*) 	on_linux_init ;;
  	*) 			;;
esac
