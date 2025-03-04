#!/bin/sh

OUTPUT=${1:-eDP-1}
LID_STATE=$(grep -o 'open\|closed' /proc/acpi/button/lid/LID0/state)

case $LID_STATE in
*closed)
  echo "> closed"
  swaymsg output $OUTPUT disable
  ;;
*open)
  echo "> open"
  swaymsg output $OUTPUT enable
  ;;
*)
  echo "Error: Could not determine lid state"
  exit 1
  ;;
esac
