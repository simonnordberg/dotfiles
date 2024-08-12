mkdir -p $HOME/bin
for x in $SCRIPT_DIR/bin/*; do ln -fsn $x $HOME/bin; done
