#!/bin/sh

date_formatted=$(date +'%Y-%m-%d %H:%M')
battery_info=$(upower --show-info $(upower --enumerate | grep 'BAT') | egrep "state|percentage" | awk '{print $2}')
audio_info=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')

# Keyboard layout
layout=$(swaymsg -t get_inputs | jq -r '.[0].xkb_active_layout_name')
case $layout in
    Swedish)
        layout_icon="🇸🇪"
        ;;
    English*)
        layout_icon="🇺🇸"
        ;;
    *)
        layout_icon="❓"
        ;;
esac

echo $audio_info 🔉 $battery_info 🔋 $date_formatted $layout_icon
