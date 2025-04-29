#!/usr/bin/env bash

if [ ! -d "$HOME/Downloads" ]; then
    echo "Downloads directory not found"
    exit 1
fi

find $HOME/Downloads/* -type f -mmin +48 -delete -print
find $HOME/Downloads/* -type d -mmin +48 -empty -delete -print
