# --- Zinit bootstrap ---
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

# --- Plugins ---
zinit wait lucid light-mode for \
  atinit"zicompinit; zicdreplay" zsh-users/zsh-syntax-highlighting \
  zsh-users/zsh-autosuggestions \
  zsh-users/zsh-completions \
  zsh-users/zsh-history-substring-search

# --- Completion ---
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select

# --- History ---
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt APPEND_HISTORY

# --- Navigation ---
setopt AUTO_CD
setopt NO_BEEP

# --- Vi mode ---
bindkey -v
export KEYTIMEOUT=1
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# --- PATH ---
path=("$HOME/.cargo/bin" "$HOME/.local/bin" $path)
typeset -U path

# --- Environment ---
export EDITOR=nvim
export VISUAL=nvim
export SDL_VIDEODRIVER=wayland,x11

# 1Password SSH agent
if [[ -S "$HOME/.1password/agent.sock" ]]; then
  export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"
fi

# --- Go ---
if command -v go &>/dev/null; then
  export GOPATH="$HOME/go"
  path=("$GOPATH/bin" $path)
fi

# --- pyenv ---
if [[ -d "$HOME/.pyenv" ]]; then
  export PYENV_ROOT="$HOME/.pyenv"
  path=("$PYENV_ROOT/bin" $path)
  eval "$(pyenv init -)"
fi

# --- NVM (lazy-loaded) ---
export NVM_DIR="$HOME/.nvm"
if [[ -d "$NVM_DIR" ]]; then
  _nvm_lazy_load() {
    unfunction nvm node npm npx 2>/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  }
  nvm()  { _nvm_lazy_load; nvm "$@" }
  node() { _nvm_lazy_load; node "$@" }
  npm()  { _nvm_lazy_load; npm "$@" }
  npx()  { _nvm_lazy_load; npx "$@" }
fi

# --- Aliases ---
alias dokku="ssh -t dokku@dokku --"

# --- Functions ---
wsudo() {
  sudo -E env \
    WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
    XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
    DISPLAY="$DISPLAY" \
    XAUTHORITY="$XAUTHORITY" \
    "$@"
}

# --- Local env ---
[[ -f "$HOME/.env" ]] && source "$HOME/.env"

# --- Prompt ---
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi
