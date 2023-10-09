#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

ln -s $SCRIPT_DIR/rubymine /usr/local/bin/rubymine
ln -s $SCRIPT_DIR/idea /usr/local/bin/idea
ln -s $SCRIPT_DIR/pycharm /usr/local/bin/pycharm
ln -s $SCRIPT_DIR/fp /usr/local/bin/fp
