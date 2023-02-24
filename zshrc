export PATH=/opt/homebrew/bin:$HOME/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"
export EDITOR='emacs -nw'

export PYENV_ROOT="$HOME/.pyenv"
export GOPATH=$HOME/go
export GOROOT="$(brew --prefix golang)/libexec"

export PATH="${GOPATH}/bin:${GOROOT}/bin:${PYENV_ROOT}/bin:$PATH"

export AWS_DEFAULT_PROFILE=legacy-sso

mkdir -p $HOME/go/{bin,src,pkg}

ZSH_THEME="blinks"
CASE_SENSITIVE="true"
HIST_STAMPS="yyyy-mm-dd"
ENABLE_CORRECTION="false"

plugins=(
    git
    macos
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

javahome() {
    unset JAVA_HOME
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

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

function awsdi() {
    aws ec2 describe-instances \
        --filter "Name=instance-state-name,Values=running" \
        --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value|[0], PublicIpAddress, State.Name]" \
        --output text
}
