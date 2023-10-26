export PATH=/opt/homebrew/bin:$HOME/bin:/usr/local/bin:/usr/local/go/bin:$HOME/.cargo/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"

# EDITOR
if command -v emacsclient 1> /dev/null; then
    export EDITOR='emacsclient -t'
elif command -v emacs 1> /dev/null; then
    export EDITOR='emacs -nw'
elif command -v vim 1> /dev/null; then
    export EDITOR='vim'
else
    export EDITOR='vi'
fi

export PYENV_ROOT="$HOME/.pyenv"
export GOPATH=$HOME/go

export PATH="${GOPATH}/bin:${GOROOT}/bin:${PYENV_ROOT}/bin:$PATH"
export AWS_DEFAULT_PROFILE=legacy-sso
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

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
    fzf
)

fpath=(/usr/local/share/zsh-completions $fpath)
source $ZSH/oh-my-zsh.sh

if command -v brew 1> /dev/null; then
  if [ -f $(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc ]; then
    source $(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc
  fi

  eval $(brew shellenv)
  export GOROOT="$(brew --prefix golang)/libexec"
fi

if command -v gpgconf 1> /dev/null; then
  export GPG_TTY="$(tty)"
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
  gpgconf --launch gpg-agent
fi

if command -v jenv 1> /dev/null; then
    eval "$(jenv init -)"
fi

if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

if [ -f ~/.rbenv/bin/rbenv ]; then
    eval "$(~/.rbenv/bin/rbenv init - zsh)"
fi

if command -v rbenv 1>/dev/null 2>&1; then
    eval "$(rbenv init -)"
fi

javahome() {
    unset JAVA_HOME
    export JAVA_HOME=$(/usr/libexec/java_home -v "$1");
    java -version
}

alias j11='javahome 11'
alias j17='javahome 17'
alias j19='javahome 19'

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

# VERSION={v1,v2,v3} weather <location>
function weather() {
    [[ "$1" != "" ]] && LOCATION="$1" || LOCATION="Gothenburg"
    [[ "$VERSION" == "" ]] && VERSION="v2"
    curl "https://${VERSION}.wttr.in/${LOCATION}"
}

function awsdi() {
    aws ec2 describe-instances \
        --filter "Name=instance-state-name,Values=running" \
        --query "Reservations[*].Instances[*].[Tags[?Key=='Name'].Value|[0], PublicIpAddress, State.Name]" \
        --output text
}

#function pomodoro() {
#    local msg="Take a break"
#    local min="${1:-25}"
#    local sec=$((min * 60))#
#
#    sleep $sec && echo "$msg" && notify-send -u critical -t 0 "Pomodoro" "$msg"
#}

# fp auto-completion
() {
  # A list of each flatpak app name in lowercase.
  # (First word of the name to be exact, so "Brave Browser" will be "brave").
  local FLATPAK_APPS=$(flatpak list --app | cut -f1 | awk '{print tolower($1)}')
  complete -W $FLATPAK_APPS fp
}

function togglescheme() {
  if command -v theme.sh 1>/dev/null 2>&1; then
      local scheme=$(/home/simon/.config/sway/themectl.sh query)

      if [ "$scheme" = "night" ];then
          theme.sh gruvbox-dark
      elif [ "$scheme" = "day" ]; then
          theme.sh gruvbox-light-soft
      fi
  fi
}

togglescheme

TRAPUSR1() {
    togglescheme
}
