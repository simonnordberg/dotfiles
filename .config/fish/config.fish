set -U fish_greeting

starship init fish | source

set -Ux PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/bin
pyenv init - | source

fish_add_path $HOME/go/bin
fish_add_path $HOME/.cargo/bin

set -Ux LS_COLORS "di=0;36:ln=0;35:so=0;33:pi=0;33:ex=0;32:bd=1;33;01:cd=1;33;01:su=0;37:sg=0;30:tw=0;37:ow=0;34:st=0;37:*.tar=1;31:*.gz=1;31:*.zip=1;31:*.bz2=1;31:*.xz=1;31"

set -Ux EDITOR nvim
set -Ux VISUAL nvim

if test -f ~/.env
    source ~/.env
end
