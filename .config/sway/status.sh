#!/bin/sh

date_formatted=$(date +'%Y-%m-%d %H:%M')
battery_info=$(upower --show-info $(upower --enumerate | grep 'BAT') | egrep "state|percentage" | awk '{print $2}')
audio_info=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')

echo $audio_info 🔉 $battery_info 🔋 $date_formatted
