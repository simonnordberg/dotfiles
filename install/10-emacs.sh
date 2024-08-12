sudo dnf install -y emacs

PRELUDE_DIR="$HOME/.emacs.d"
PRELUDE_INSTALLER="https://github.com/bbatsov/prelude/raw/master/utils/installer.sh"

[[ ! -d $PRELUDE_DIR ]] && curl -L $PRELUDE_INSTALLER | sh
ln -fsn $SCRIPT_DIR/.emacs.d/personal/config.el $HOME/.emacs.d/personal/config.el

mkdir -p $HOME/.config/systemd/user
ln -fsn $SCRIPT_DIR/.config/systemd/user/emacs.service $HOME/.config/systemd/user/emacs.service
systemctl --user is-active emacs && systemctl --user restart emacs || systemctl --user enable --now emacs
