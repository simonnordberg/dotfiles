mkdir -p $HOME/bin
for x in $BASE_DIR/bin/*; do ln -fsn $x $HOME/bin; done
