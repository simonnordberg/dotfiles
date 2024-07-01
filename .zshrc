PATH="$PATH:/usr/local/go/bin:/opt/homebrew/path:$HOME/bin:$HOME/.local/bin"

if [ -d "$HOME/.cargo" ]; then
    . "$HOME/.cargo/env"
fi

export LS_COLORS="di=0;36:ln=0;35:so=0;33:pi=0;33:ex=0;32:bd=1;33;01:cd=1;33;01:su=0;37:sg=0;30:tw=0;37:ow=0;34:st=0;37:*.tar=1;31:*.gz=1;31:*.zip=1;31:*.bz2=1;31:*.xz=1;31"
export LSCOLORS="exgxcxdxbxegedabagacad"

export PATH
export TERM=foot-direct

export ZSH="$HOME/.oh-my-zsh"

if command -v emacsclient 1> /dev/null; then
    export EDITOR='emacsclient -t'
elif command -v emacs 1> /dev/null; then
    export EDITOR='emacs -nw'
elif command -v vim 1> /dev/null; then
    export EDITOR='vim'
else
    export EDITOR='vi'
fi

export ALTERNATE_EDITOR=""
alias e="emacsclient --tty"

export PYENV_ROOT="$HOME/.pyenv"
export GOPATH=$HOME/go

mkdir -p $HOME/go/{bin,src,pkg}

export PATH="${GOPATH}/bin:${GOROOT}/bin:${PYENV_ROOT}/bin:$PATH"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

ZSH_THEME="alanpeabody"
CASE_SENSITIVE="true"
HIST_STAMPS="yyyy-mm-dd"
ENABLE_CORRECTION="false"

export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true

plugins=(
    zsh-nvm
    git
    macos
    dotenv
    fzf
    evalcache
)

fpath=(/usr/local/share/zsh-completions $fpath)
source $ZSH/oh-my-zsh.sh

if command -v brew 1> /dev/null; then
    _evalcache brew shellenv
fi

if command -v gpgconf 1> /dev/null; then
    mkdir -p $HOME/.gnupg
    export GPG_TTY="$(tty)"
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    gpgconf --launch gpg-agent
fi

if command -v jenv 1> /dev/null; then
    _evalcache jenv init -
fi

if command -v pyenv 1>/dev/null 2>&1; then
    _evalcache pyenv init -
    _evalcache pyenv virtualenv-init -
fi

if command -v rbenv 1>/dev/null 2>&1; then
    _evalcache rbenv init -
fi

javahome() {
    export JAVA_HOME=$(/usr/libexec/java_home -v "$1");
    java -version
}

alias j11='javahome 11'
alias j17='javahome 17'
alias j19='javahome 19'

# VERSION={v1,v2,v3} weather <location>
function weather() {
    [[ "$1" != "" ]] && LOCATION="$1" || LOCATION="Gothenburg"
    [[ "$VERSION" == "" ]] && VERSION="v2"
    curl "https://${VERSION}.wttr.in/${LOCATION}"
}

# fp auto-completion
() {
    local FLATPAK_APPS=$(flatpak list --app | cut -f1 | awk '{print tolower($1)}')
    complete -W $FLATPAK_APPS fp
}

function togglescheme() {
    if command -v theme.sh 1>/dev/null 2>&1; then
        local scheme=$($HOME/.config/sway/themectl.sh query)

        if [ "$scheme" = "night" ];then
            theme.sh solarized-dark
        elif [ "$scheme" = "day" ]; then
            theme.sh solarized-light
        fi
    fi
}

togglescheme

TRAPUSR1() {
    togglescheme
}
