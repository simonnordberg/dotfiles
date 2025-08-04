set -U fish_greeting

fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.local/bin

if command -v starship &> /dev/null
    starship init fish | source
end

if command -v pyenv &> /dev/null
    set -Ux PYENV_ROOT $HOME/.pyenv
    fish_add_path $PYENV_ROOT/bin
    pyenv init - | source
end

if command -v go &> /dev/null
    set -x -U GOPATH $HOME/go
    fish_add_path $GOPATH/bin
end


set -Ux LS_COLORS "di=0;36:ln=0;35:so=0;33:pi=0;33:ex=0;32:bd=1;33;01:cd=1;33;01:su=0;37:sg=0;30:tw=0;37:ow=0;34:st=0;37:*.tar=1;31:*.gz=1;31:*.zip=1;31:*.bz2=1;31:*.xz=1;31"

set -Ux EDITOR nvim
set -Ux VISUAL nvim

set -Ux SDL_VIDEODRIVER wayland,x11

if command -v 1password &> /dev/null
    set -Ux SSH_AUTH_SOCK $HOME/.1password/agent.sock
end

alias dokku "ssh -t dokku@dokku --"

if test -f $HOME/.env
    source $HOME/.env
end
