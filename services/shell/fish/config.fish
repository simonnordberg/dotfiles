set -U fish_greeting

fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.local/bin

if command -v starship &>/dev/null
    starship init fish | source
end

if command -v pyenv &>/dev/null
    set -Ux PYENV_ROOT $HOME/.pyenv
    fish_add_path $PYENV_ROOT/bin
    pyenv init - | source
end

if command -v go &>/dev/null
    set -x -U GOPATH $HOME/go
    fish_add_path $GOPATH/bin
end

set -Ux EDITOR nvim
set -Ux VISUAL nvim

set -Ux SDL_VIDEODRIVER wayland,x11

if command -v 1password &>/dev/null
    set -Ux SSH_AUTH_SOCK $HOME/.1password/agent.sock
end

alias dokku "ssh -t dokku@dokku --"

if test -f $HOME/.env
    source $HOME/.env
end
