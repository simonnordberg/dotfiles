#!/bin/sh

current=$(gsettings get org.gnome.desktop.interface color-scheme)

if [ "$current" = "'prefer-light'" ]; then
    scheme=day
else
    scheme=night
fi

case "$1" in
    toggle)
        if [ "$scheme" = "night" ]; then
            scheme=day
        else
            scheme=night
        fi

        ;;

    night|day)
        scheme="$1"
        ;;

    query)
        echo "$scheme"
        exit
        ;;

    *)
        echo "Usage: $0 <toggle|night|day|query>"
        exit
        ;;

esac

if [ "$scheme" = "night" ]; then
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
else
    gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-light"
fi

pkill -USR1 zsh
