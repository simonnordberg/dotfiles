#!/bin/sh

OUTPUT=${1:-eDP-1}

if grep -q closed /proc/acpi/button/lid/*/state; then
  swaymsg output $OUTPUT disable
else
  swaymsg output $OUTPUT enable
fi
