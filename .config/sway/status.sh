#!/bin/sh

date="📅 $(date +'%Y-%m-%d %H:%M')"
battery="🔋 $(upower --show-info $(upower --enumerate | grep 'BAT') | egrep "state|percentage" | awk '{print $2}' | xargs)"
audio="🔉 $(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')"
wifi="📡 $( (iwgetid | grep -o '"[^"]\+"') | xargs)"
keyboard=$(swaymsg -t get_inputs | jq -r 'map(select(.xkb_active_layout_name != null)) | .[0].xkb_active_layout_name')

case $keyboard in
    Swedish)
        keyboard="🇸🇪"
        ;;
    English*)
        keyboard="🇺🇸"
        ;;
    *)
        keyboard="❓"
        ;;
esac

echo "$wifi\t$audio\t$battery\t$date\t$keyboard"
