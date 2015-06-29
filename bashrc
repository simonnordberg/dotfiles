# Git
source ~/.git-completion.bash
source ~/.git-prompt.sh

# Misc
export PATH=~/bin:/usr/local/bin:/usr/local/sbin:$HOME/.rvm/bin:/usr/local/heroku/bin:$PATH
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`

# JBoss
export JBOSS_HOME=/usr/local/opt/wildfly-as/libexec
export PATH=${PATH}:${JBOSS_HOME}/bin

eval "$(rbenv init -)"

# Python
export PIP_REQUIRE_VIRTUALENV=true
export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache

# Functions
docker_start () {
  boot2docker init
  boot2docker start
  $(boot2docker shellinit)
}

docker_remove_all() {
  docker rm `docker ps --no-trunc -aq`
}

export EDITOR='emacsclient -t -a emacs'
alias ec='emacsclient -t'

MAGENTA="\[\033[0;35m\]"
YELLOW="\[\033[0;33m\]"
BLUE="\[\033[34m\]"
LIGHT_GRAY="\[\033[0;37m\]"
CYAN="\[\033[0;36m\]"
GREEN="\[\033[0;32m\]"
GIT_PS1_SHOWDIRTYSTATE=true
export LS_OPTIONS='--color=auto'
export CLICOLOR='Yes'
export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD

# Lang
export LC_ALL=en_US.UTF-8
export LANG=en_us.UTF-8

export PS1=$LIGHT_GRAY"\u@\h"'$(
    if [[ $(__git_ps1) =~ \*\)$ ]]
    # a file has been modified but not added
    then echo "'$YELLOW'"$(__git_ps1 " (%s)")
    elif [[ $(__git_ps1) =~ \+\)$ ]]
    # a file has been added, but not commited
    then echo "'$MAGENTA'"$(__git_ps1 " (%s)")
    # the state is clean, changes are commited
    else echo "'$CYAN'"$(__git_ps1 " (%s)")
    fi)'$BLUE" \w"$GREEN": "

# AWS
export AWS_DEFAULT_PROFILE=eu-central-1

