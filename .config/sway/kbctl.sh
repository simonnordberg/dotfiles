#!/bin/sh

DIR="$HOME/.config/sway/config.d"
CONFIG="$DIR/colemak.conf"

if [ ! -d "$DIR" ]; then
    mkdir -p "$DIR"
fi


if [ -f "$CONFIG" ]; then
    rm -f "$CONFIG"
else
    cat > "$CONFIG" <<EOF
input                   "type:keyboard" {
    repeat_delay        250
    repeat_rate         45
    xkb_layout          se
    xkb_variant         cmk_ed_us
    xkb_model           pc105awide
    xkb_options         ctrl:nocaps
}
EOF
fi

swaymsg reload
